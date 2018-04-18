#[macro_use] extern crate log;
extern crate syntex_syntax;
extern crate toml;
extern crate env_logger;
#[macro_use] extern crate clap;

extern crate racer;

use racer::{Match, MatchType, FileCache, Session, Coordinate};
use std::fs::File;
use std::path::{Path, PathBuf};
use std::io::{self, BufRead, Read};
use clap::{App, AppSettings, Arg, ArgMatches, SubCommand};

fn match_with_snippet_fn(m: Match, session: &Session, interface: Interface) {
    let Coordinate { line: linenum, column: charnum } = m.coords.unwrap();
    if m.matchstr == "" {
        panic!("MATCHSTR is empty - waddup?");
    }

    let snippet = racer::snippet_for_match(&m, session);
    interface.emit(Message::MatchWithSnippet(m.matchstr, snippet, linenum, charnum,
                                             m.filepath.as_path(), m.mtype, m.contextstr, m.docs));
}

fn match_fn(m: Match, interface: Interface) {
    if let Some(coords) = m.coords {
        let Coordinate { line: linenum, column: charnum } = coords;
        interface.emit(Message::Match(m.matchstr, linenum, charnum, m.filepath.as_path(),
                                      m.mtype, m.contextstr));
    } else {
        error!("Could not resolve file coords for match {:?}", m);
    }
}

fn complete(cfg: Config, print_type: CompletePrinter) {
    if cfg.fqn.is_some() {
        return external_complete(cfg, print_type);
    }
    complete_by_line_coords(cfg, print_type);
}

fn complete_by_line_coords(cfg: Config,
                           print_type: CompletePrinter) {
    // input: linenum, colnum, fname
    let tb = std::thread::Builder::new().name("searcher".to_owned());
    let interface = cfg.interface;

    // PD: this probably sucks for performance, but lots of plugins
    // end up failing and leaving tmp files around if racer crashes,
    // so catch the crash.
    let res = tb.spawn(move || {
        run_the_complete_fn(&cfg, print_type);
    }).unwrap();
    if let Err(e) = res.join() {
        error!("Search thread paniced: {:?}", e);
    }

    interface.emit(Message::End);
}

#[derive(Debug)]
enum CompletePrinter {
    Normal,
    WithSnippets
}

fn read_file_from_stdin() -> String {
    let mut rawbytes = Vec::new();

    let stdin = io::stdin();
    stdin.lock().read_until(0x04, &mut rawbytes).expect("read until EOT");

    String::from_utf8(rawbytes).expect("utf8 from stdin")
}

fn read_file<P>(path: P) -> io::Result<String>
    where P: AsRef<Path>
{
    let mut res = String::new();
    let mut f = try!(File::open(path));

    try!(f.read_to_string(&mut res));
    Ok(res)
}

fn load_query_file<P, S>(path: P, sub: S, session: &Session)
    where P: Into<PathBuf>,
          S: AsRef<Path>
{
    let path = path.into();
    let sub = sub.as_ref();

    if sub.to_str() == Some("-") {
        let contents = read_file_from_stdin();
        session.cache_file_contents(path, contents);
    } else if sub != path {
        let contents = read_file(sub).unwrap();
        session.cache_file_contents(path, contents);
    }
}

fn run_the_complete_fn(cfg: &Config, print_type: CompletePrinter) {
    let fn_path = cfg.fn_name.as_ref().unwrap();
    let substitute_file = cfg.substitute_file.as_ref().unwrap_or(fn_path);

    let cache = FileCache::default();
    let session = Session::new(&cache);

    load_query_file(&fn_path, &substitute_file, &session);

    if let Some(expanded) = racer::expand_ident(&fn_path, cfg.coords(), &session) {
        cfg.interface.emit(Message::Prefix(expanded.start(), expanded.pos(), expanded.ident()));

        for m in racer::complete_from_file(&fn_path, cfg.coords(), &session) {
            match print_type {
                CompletePrinter::Normal => match_fn(m, cfg.interface),
                CompletePrinter::WithSnippets => match_with_snippet_fn(m, &session, cfg.interface),
            };
        }
    }
}

/// Completes a fully qualified name specified on command line
fn external_complete(cfg: Config, print_type: CompletePrinter) {
    let cwd = Path::new(".");
    let cache = FileCache::default();
    let session = Session::new(&cache);

    for m in racer::complete_fully_qualified_name(cfg.fqn.as_ref().unwrap(), &cwd, &session) {
        match print_type {
            CompletePrinter::Normal => match_fn(m, cfg.interface),
            CompletePrinter::WithSnippets => match_with_snippet_fn(m, &session, cfg.interface),
        }
    }
}

fn prefix(cfg: Config) {
    let fn_path = cfg.fn_name.as_ref().unwrap();
    let substitute_file = cfg.substitute_file.as_ref().unwrap_or(fn_path);
    let cache = FileCache::default();
    let session = Session::new(&cache);

    // Cache query file in session
    load_query_file(&fn_path, &substitute_file, &session);

    // print the start, end, and the identifier prefix being matched
    let expanded = racer::expand_ident(fn_path, cfg.coords(), &session).unwrap();
    cfg.interface.emit(Message::Prefix(expanded.start(), expanded.pos(), expanded.ident()));
}

fn find_definition(cfg: Config) {
    let fn_path = cfg.fn_name.as_ref().unwrap();
    let substitute_file = cfg.substitute_file.as_ref().unwrap_or(fn_path);
    let cache = FileCache::default();
    let session = Session::new(&cache);

    // Cache query file in session
    load_query_file(&fn_path, &substitute_file, &session);

    racer::find_definition(fn_path, cfg.coords(), &session)
        .map(|m| match_fn(m, cfg.interface));
    cfg.interface.emit(Message::End);
}

fn validate_rust_src_path_env_var() {
    match racer::check_rust_src_env_var() {
        Ok(_) => (),
        Err(err) => {
            println!("{}", err);
            std::process::exit(1);
        },
    }

}

fn daemon(cfg: Config) {
    let mut input = String::new();
    while let Ok(n) = io::stdin().read_line(&mut input) {
        // '\n' == 1
        if n == 1 {
            break;
        }
        // We add the setting NoBinaryName because in daemon mode we won't be passed the preceeding
        // binary name
        let cli = build_cli().setting(AppSettings::NoBinaryName);
        let matches = match cfg.interface {
            Interface::Text => cli.get_matches_from(input.trim_right().split_whitespace()),
            Interface::TabText => cli.get_matches_from(input.trim_right().split('\t'))
        };
        run(matches, cfg.interface);

        input.clear();
    }
}

enum Message<'a> {
    End,
    Prefix(usize, usize, &'a str),
    Match(String, usize, usize, &'a Path, MatchType, String),
    MatchWithSnippet(String, String, usize, usize, &'a Path, MatchType, String, String),
}

#[derive(Copy, Clone)]
enum Interface {
    Text,    // The original human-readable format.
    TabText, // Machine-readable format.  This is basically the same as Text, except that all field
             // separators are replaced with tabs.
             // In `daemon` mode tabs are also used to delimit command arguments.
}

impl Default for Interface {
    fn default() -> Self { Interface::Text }
}

impl Interface {
    fn emit(&self, message: Message) {
        match message {
            Message::End => println!("END"),
            Message::Prefix(start, pos, text) => match *self {
                Interface::Text => println!("PREFIX {},{},{}", start, pos, text),
                Interface::TabText => println!("PREFIX\t{}\t{}\t{}", start, pos, text),
            },
            Message::Match(mstr, linenum, charnum, path, mtype, context) => match *self {
                Interface::Text => {
                    let context = context.split_whitespace().collect::<Vec<&str>>().join(" ");
                    println!("MATCH {},{},{},{},{:?},{}",
                             mstr, linenum, charnum, path.display(), mtype, context);
                }
                Interface::TabText => {
                    let context = context.split_whitespace().collect::<Vec<&str>>().join(" ");
                    println!("MATCH\t{}\t{}\t{}\t{}\t{:?}\t{}",
                             mstr, linenum, charnum, path.display(), mtype, context);
                }
            },
            Message::MatchWithSnippet(mstr, snippet, linenum, charnum, path,
                                      mtype, context, docs) => match *self {
                Interface::Text => {
                    let context = context.replace(";", "\\;").split_whitespace()
                                                             .collect::<Vec<&str>>().join(" ");
                    let docs = format!("{:?}", docs).replace(";", "\\;");
                    println!("MATCH {};{};{};{};{};{:?};{};{}",
                             mstr, snippet, linenum, charnum, path.display(), mtype, context, docs);
                }
                Interface::TabText => {
                    let context = context.replace("\t", "\\t").split_whitespace()
                                                              .collect::<Vec<&str>>().join(" ");
                    println!("MATCH\t{}\t{}\t{}\t{}\t{}\t{:?}\t{}\t{:?}",
                             mstr, snippet, linenum, charnum, path.display(), mtype, context, docs);
                }
            }
        }
    }
}

#[derive(Default)]
struct Config {
    fqn: Option<String>,
    linenum: usize,
    charnum: usize,
    fn_name: Option<PathBuf>,
    substitute_file: Option<PathBuf>,
    interface: Interface,
}

impl Config {
    fn coords(&self) -> Coordinate {
        Coordinate {
            line: self.linenum,
            column: self.charnum
        }
    }
}

impl<'a> From<&'a ArgMatches<'a>> for Config {
    fn from(m: &'a ArgMatches) -> Self {
        // We check for charnum because it's the second argument, which means more than just
        // an FQN was used (i.e. racer complete <linenum> <charnum> <fn_name> [substitute_file])
        if m.is_present("charnum") {
             let cfg = Config {
                charnum: value_t_or_exit!(m.value_of("charnum"), usize),
                fn_name: m.value_of("path").map(PathBuf::from),
                substitute_file: m.value_of("substitute_file").map(PathBuf::from),
                ..Default::default()
             };
             if !m.is_present("linenum") {
            // Becasue of the hack to allow fqn and linenum to share a single arg we set FQN
            // to None and set the charnum correctly using the FQN arg so there's no
            // hackery later
                return Config {linenum: value_t_or_exit!(m.value_of("fqn"), usize), .. cfg };
            }
            return Config {linenum: value_t_or_exit!(m.value_of("linenum"), usize), .. cfg };
        }
        Config {fqn: m.value_of("fqn").map(ToOwned::to_owned), ..Default::default() }
    }
}

fn build_cli<'a, 'b>() -> App<'a, 'b> {
    // we use the more verbose "Builder Pattern" to create the CLI because it's a littel faster
    // than the less verbose "Usage String" method...faster, meaning runtime speed since that's
    // extremely important here
    App::new("racer")
        .version(env!("CARGO_PKG_VERSION"))
        .author("Phil Dawes")
        .about("A Rust code completion utility")
        .settings(&[AppSettings::GlobalVersion,
		    AppSettings::SubcommandRequiredElseHelp])
        .arg(Arg::with_name("interface")
            .long("interface")
            .short("i")
            .takes_value(true)
            .possible_value("text")
            .possible_value("tab-text")
            .value_name("mode")
            .help("Interface mode"))
        .subcommand(SubCommand::with_name("complete")
            .about("performs completion and returns matches")
            // We set an explicit usage string here, instead of letting `clap` write one due to
            // using a single arg for multiple purposes
            .usage("racer complete <fqn>\n    \
                    racer complete <linenum> <charnum> <path> [substitute_file]")
            // Next we make it an error to run without any args
            .setting(AppSettings::ArgRequiredElseHelp)
            // Because we want a single arg to play two roles and be compatible with previous
            // racer releases, we have to be a little hacky here...
            //
            // We start by making 'fqn' the first positional arg, which will hold this dual value
            // of either an FQN as it says, or secretly a line-number
            .arg(Arg::with_name("fqn")
                .help("complete with a fully-qualified-name (e.g. std::io::)"))
            .arg(Arg::with_name("charnum")
                .help("The char number to search for matches")
                .requires("path"))
            .arg(Arg::with_name("path")
                .help("The path to search for name to match"))
            .arg(Arg::with_name("substitute_file")
                .help("An optional substitute file"))
            // 'linenum' **MUST** be last (or have the highest index so that it's never actually
            // used by the user, but still appears in the help text)
            .arg(Arg::with_name("linenum")
                .help("The line number at which to find the match")))
        .subcommand(SubCommand::with_name("daemon")
            .about("start a process that receives the above commands via stdin"))
        .subcommand(SubCommand::with_name("find-definition")
            .about("finds the definition of a function")
            .arg(Arg::with_name("linenum")
                .help("The line number at which to find the match")
                .required(true))
            .arg(Arg::with_name("charnum")
                .help("The char number at which to find the match")
                .required(true))
            .arg(Arg::with_name("path")
                .help("The path to search for name to match")
                .required(true))
            .arg(Arg::with_name("substitute_file")
                .help("An optional substitute file")))
        .subcommand(SubCommand::with_name("prefix")
            .arg(Arg::with_name("linenum")
                .help("The line number at which to find the match")
                .required(true))
            .arg(Arg::with_name("charnum")
                .help("The char number at which to find the match")
                .required(true))
            .arg(Arg::with_name("path")
                .help("The path to search for the match to prefix")
                .required(true)))
        .subcommand(SubCommand::with_name("complete-with-snippet")
            .about("performs completion and returns more detailed matches")
            .usage("racer complete-with-snippet <fqn>\n    \
                    racer complete-with-snippet <linenum> <charnum> <path> [substitute_file]")
            .setting(AppSettings::ArgRequiredElseHelp)
            .arg(Arg::with_name("fqn")
                .help("complete with a fully-qualified-name (e.g. std::io::)"))
            .arg(Arg::with_name("charnum")
                .help("The char number to search for matches")
                .requires("path"))
            .arg(Arg::with_name("path")
                .help("The path to search for name to match"))
            .arg(Arg::with_name("substitute_file")
                .help("An optional substitute file"))
            .arg(Arg::with_name("linenum")
                .help("The line number at which to find the match")))
        .after_help("For more information about a specific command try 'racer <command> --help'")
}

fn main() {
    env_logger::init().unwrap();

    let matches = build_cli().get_matches();
    let interface = match matches.value_of("interface") {
            Some("tab-text") => Interface::TabText,
            Some("text") | _ => Interface::Text
        };
    
    validate_rust_src_path_env_var();
    
    run(matches, interface);
}

fn run(m: ArgMatches, interface: Interface) {
    use CompletePrinter::{Normal, WithSnippets};
    // match raw subcommand, and get it's sub-matches "m"
    if let (name, Some(sub_m)) = m.subcommand() {
        let mut cfg = Config::from(sub_m);
        cfg.interface = interface;
        match name {
            "daemon"                => daemon(cfg),
            "prefix"                => prefix(cfg),
            "complete"              => complete(cfg, Normal),
            "complete-with-snippet" => complete(cfg, WithSnippets),
            "find-definition"       => find_definition(cfg),
            _                       => unreachable!()
        }
    }
}
