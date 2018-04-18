//! This module supports deserializing from primitives with the `ValueDeserializer` trait.

#[cfg(feature = "std")]
use std::collections::{
    BTreeMap,
    BTreeSet,
    HashMap,
    HashSet,
    btree_map,
    btree_set,
    hash_map,
    hash_set,
};
#[cfg(feature = "std")]
use std::borrow::Cow;
#[cfg(feature = "std")]
use std::vec;

#[cfg(all(feature = "collections", not(feature = "std")))]
use collections::{
    BTreeMap,
    BTreeSet,
    Vec,
    String,
    btree_map,
    btree_set,
    vec,
};
#[cfg(all(feature = "collections", not(feature = "std")))]
use collections::borrow::Cow;

#[cfg(all(feature = "unstable", feature = "collections"))]
use collections::borrow::ToOwned;

use core::hash::Hash;
#[cfg(feature = "std")]
use std::error;
#[cfg(not(feature = "std"))]
use error;

use core::fmt;
use core::marker::PhantomData;

use de;
use bytes;

///////////////////////////////////////////////////////////////////////////////

/// This represents all the possible errors that can occur using the `ValueDeserializer`.
#[derive(Clone, Debug, PartialEq)]
pub enum Error {
    /// The value had some custom error.
    #[cfg(any(feature = "std", feature = "collections"))]
    Custom(String),
    /// The value had some custom error.
    #[cfg(all(not(feature = "std"), not(feature = "collections")))]
    Custom(&'static str),

    /// The value had an incorrect type.
    InvalidType(de::Type),

    /// The value had an invalid length.
    InvalidLength(usize),

    /// The value is invalid and cannot be deserialized.
    #[cfg(any(feature = "std", feature = "collections"))]
    InvalidValue(String),
    /// The value is invalid and cannot be deserialized.
    #[cfg(all(not(feature = "std"), not(feature = "collections")))]
    InvalidValue(&'static str),

    /// EOF while deserializing a value.
    EndOfStream,

    /// Unknown variant in enum.
    #[cfg(any(feature = "std", feature = "collections"))]
    UnknownVariant(String),
    /// Unknown variant in enum.
    #[cfg(all(not(feature = "std"), not(feature = "collections")))]
    UnknownVariant(&'static str),

    /// Unknown field in struct.
    #[cfg(any(feature = "std", feature = "collections"))]
    UnknownField(String),
    /// Unknown field in struct.
    #[cfg(all(not(feature = "std"), not(feature = "collections")))]
    UnknownField(&'static str),

    /// Struct is missing a field.
    MissingField(&'static str),
}

impl de::Error for Error {
    #[cfg(any(feature = "std", feature = "collections"))]
    fn custom<T: Into<String>>(msg: T) -> Self { Error::Custom(msg.into()) }

    #[cfg(all(not(feature = "std"), not(feature = "collections")))]
    fn custom<T: Into<&'static str>>(msg: T) -> Self { Error::Custom(msg.into()) }

    fn end_of_stream() -> Self { Error::EndOfStream }
    fn invalid_type(ty: de::Type) -> Self { Error::InvalidType(ty) }

    #[cfg(any(feature = "std", feature = "collections"))]
    fn invalid_value(msg: &str) -> Self { Error::InvalidValue(msg.to_owned()) }

    #[cfg(all(not(feature = "std"), not(feature = "collections")))]
    fn invalid_value(msg: &str) -> Self { Error::InvalidValue("invalid value") }

    fn invalid_length(len: usize) -> Self { Error::InvalidLength(len) }

    #[cfg(any(feature = "std", feature = "collections"))]
    fn unknown_variant(variant: &str) -> Self { Error::UnknownVariant(String::from(variant)) }
    #[cfg(any(feature = "std", feature = "collections"))]
    fn unknown_field(field: &str) -> Self { Error::UnknownField(String::from(field)) }

    #[cfg(all(not(feature = "std"), not(feature = "collections")))]
    fn unknown_variant(variant: &str) -> Self { Error::UnknownVariant("unknown variant") }
    #[cfg(all(not(feature = "std"), not(feature = "collections")))]
    fn unknown_field(field: &str) -> Self { Error::UnknownField("unknown field") }
    fn missing_field(field: &'static str) -> Self { Error::MissingField(field) }
}

impl fmt::Display for Error {
    fn fmt(&self, formatter: &mut fmt::Formatter) -> Result<(), fmt::Error> {
        match *self {
            Error::Custom(ref s) => write!(formatter, "{}", s),
            Error::EndOfStream => formatter.write_str("End of stream"),
            Error::InvalidType(ty) => write!(formatter, "Invalid type, expected `{:?}`", ty),
            Error::InvalidValue(ref value) => write!(formatter, "Invalid value: {}", value),
            Error::InvalidLength(len) => write!(formatter, "Invalid length: {}", len),
            Error::UnknownVariant(ref variant) => {
                write!(formatter, "Unknown variant: {}", variant)
            }
            Error::UnknownField(ref field) => write!(formatter, "Unknown field: {}", field),
            Error::MissingField(field) => write!(formatter, "Missing field: {}", field),
        }
    }
}

impl error::Error for Error {
    fn description(&self) -> &str {
        "Serde Deserialization Error"
    }

    fn cause(&self) -> Option<&error::Error> {
        None
    }
}

///////////////////////////////////////////////////////////////////////////////

/// This trait converts primitive types into a deserializer.
pub trait ValueDeserializer<E: de::Error = Error> {
    /// The actual deserializer type.
    type Deserializer: de::Deserializer<Error=E>;

    /// Convert this value into a deserializer.
    fn into_deserializer(self) -> Self::Deserializer;
}

///////////////////////////////////////////////////////////////////////////////

impl<E> ValueDeserializer<E> for ()
    where E: de::Error,
{
    type Deserializer = UnitDeserializer<E>;

    fn into_deserializer(self) -> UnitDeserializer<E> {
        UnitDeserializer(PhantomData)
    }
}

/// A helper deserializer that deserializes a `()`.
pub struct UnitDeserializer<E>(PhantomData<E>);

impl<E> de::Deserializer for UnitDeserializer<E>
    where E: de::Error
{
    type Error = E;

    de_forward_to_deserialize!{
        deserialize_bool,
        deserialize_f64, deserialize_f32,
        deserialize_u8, deserialize_u16, deserialize_u32, deserialize_u64, deserialize_usize,
        deserialize_i8, deserialize_i16, deserialize_i32, deserialize_i64, deserialize_isize,
        deserialize_char, deserialize_str, deserialize_string,
        deserialize_ignored_any,
        deserialize_bytes,
        deserialize_unit_struct, deserialize_unit,
        deserialize_seq, deserialize_seq_fixed_size,
        deserialize_map, deserialize_newtype_struct, deserialize_struct_field,
        deserialize_tuple,
        deserialize_enum,
        deserialize_struct, deserialize_tuple_struct
    }

    fn deserialize<V>(&mut self, mut visitor: V) -> Result<V::Value, Self::Error>
        where V: de::Visitor,
    {
        visitor.visit_unit()
    }

    fn deserialize_option<V>(&mut self, mut visitor: V) -> Result<V::Value, Self::Error>
        where V: de::Visitor,
    {
        visitor.visit_none()
    }
}

///////////////////////////////////////////////////////////////////////////////

macro_rules! primitive_deserializer {
    ($ty:ty, $name:ident, $method:ident) => {
        /// A helper deserializer that deserializes a number.
        pub struct $name<E>(Option<$ty>, PhantomData<E>);

        impl<E> ValueDeserializer<E> for $ty
            where E: de::Error,
        {
            type Deserializer = $name<E>;

            fn into_deserializer(self) -> $name<E> {
                $name(Some(self), PhantomData)
            }
        }

        impl<E> de::Deserializer for $name<E>
            where E: de::Error,
        {
            type Error = E;

            de_forward_to_deserialize!{
                deserialize_bool,
                deserialize_f64, deserialize_f32,
                deserialize_u8, deserialize_u16, deserialize_u32, deserialize_u64, deserialize_usize,
                deserialize_i8, deserialize_i16, deserialize_i32, deserialize_i64, deserialize_isize,
                deserialize_char, deserialize_str, deserialize_string,
                deserialize_ignored_any,
                deserialize_bytes,
                deserialize_unit_struct, deserialize_unit,
                deserialize_seq, deserialize_seq_fixed_size,
                deserialize_map, deserialize_newtype_struct, deserialize_struct_field,
                deserialize_tuple,
                deserialize_enum,
                deserialize_struct, deserialize_tuple_struct,
                deserialize_option
            }

            fn deserialize<V>(&mut self, mut visitor: V) -> Result<V::Value, Self::Error>
                where V: de::Visitor,
            {
                match self.0.take() {
                    Some(v) => visitor.$method(v),
                    None => Err(de::Error::end_of_stream()),
                }
            }
        }
    }
}

primitive_deserializer!(bool, BoolDeserializer, visit_bool);
primitive_deserializer!(i8, I8Deserializer, visit_i8);
primitive_deserializer!(i16, I16Deserializer, visit_i16);
primitive_deserializer!(i32, I32Deserializer, visit_i32);
primitive_deserializer!(i64, I64Deserializer, visit_i64);
primitive_deserializer!(isize, IsizeDeserializer, visit_isize);
primitive_deserializer!(u8, U8Deserializer, visit_u8);
primitive_deserializer!(u16, U16Deserializer, visit_u16);
primitive_deserializer!(u32, U32Deserializer, visit_u32);
primitive_deserializer!(u64, U64Deserializer, visit_u64);
primitive_deserializer!(usize, UsizeDeserializer, visit_usize);
primitive_deserializer!(f32, F32Deserializer, visit_f32);
primitive_deserializer!(f64, F64Deserializer, visit_f64);
primitive_deserializer!(char, CharDeserializer, visit_char);

///////////////////////////////////////////////////////////////////////////////

/// A helper deserializer that deserializes a `&str`.
pub struct StrDeserializer<'a, E>(Option<&'a str>, PhantomData<E>);

impl<'a, E> ValueDeserializer<E> for &'a str
    where E: de::Error,
{
    type Deserializer = StrDeserializer<'a, E>;

    fn into_deserializer(self) -> StrDeserializer<'a, E> {
        StrDeserializer(Some(self), PhantomData)
    }
}

impl<'a, E> de::Deserializer for StrDeserializer<'a, E>
    where E: de::Error,
{
    type Error = E;

    fn deserialize<V>(&mut self, mut visitor: V) -> Result<V::Value, Self::Error>
        where V: de::Visitor,
    {
        match self.0.take() {
            Some(v) => visitor.visit_str(v),
            None => Err(de::Error::end_of_stream()),
        }
    }

    fn deserialize_enum<V>(&mut self,
                     _name: &str,
                     _variants: &'static [&'static str],
                     mut visitor: V) -> Result<V::Value, Self::Error>
        where V: de::EnumVisitor,
    {
        visitor.visit(self)
    }

    de_forward_to_deserialize!{
        deserialize_bool,
        deserialize_f64, deserialize_f32,
        deserialize_u8, deserialize_u16, deserialize_u32, deserialize_u64, deserialize_usize,
        deserialize_i8, deserialize_i16, deserialize_i32, deserialize_i64, deserialize_isize,
        deserialize_char, deserialize_str, deserialize_string,
        deserialize_ignored_any,
        deserialize_bytes,
        deserialize_unit_struct, deserialize_unit,
        deserialize_seq, deserialize_seq_fixed_size,
        deserialize_map, deserialize_newtype_struct, deserialize_struct_field,
        deserialize_tuple,
        deserialize_struct, deserialize_tuple_struct,
        deserialize_option
    }
}

impl<'a, E> de::VariantVisitor for StrDeserializer<'a, E>
    where E: de::Error,
{
    type Error = E;

    fn visit_variant<T>(&mut self) -> Result<T, Self::Error>
        where T: de::Deserialize,
    {
        de::Deserialize::deserialize(self)
    }

    fn visit_unit(&mut self) -> Result<(), Self::Error> {
        Ok(())
    }

    fn visit_newtype<T>(&mut self) -> Result<T, Self::Error>
        where T: super::Deserialize,
    {
        let (value,) = try!(self.visit_tuple(1, super::impls::TupleVisitor1::new()));
        Ok(value)
    }

    fn visit_tuple<V>(&mut self,
                      _len: usize,
                      _visitor: V) -> Result<V::Value, Self::Error>
        where V: super::Visitor
    {
        Err(super::Error::invalid_type(super::Type::TupleVariant))
    }

    fn visit_struct<V>(&mut self,
                       _fields: &'static [&'static str],
                       _visitor: V) -> Result<V::Value, Self::Error>
        where V: super::Visitor
    {
        Err(super::Error::invalid_type(super::Type::StructVariant))
    }
}

///////////////////////////////////////////////////////////////////////////////

/// A helper deserializer that deserializes a `String`.
#[cfg(any(feature = "std", feature = "collections"))]
pub struct StringDeserializer<E>(Option<String>, PhantomData<E>);

#[cfg(any(feature = "std", feature = "collections"))]
impl<E> ValueDeserializer<E> for String
    where E: de::Error,
{
    type Deserializer = StringDeserializer<E>;

    fn into_deserializer(self) -> StringDeserializer<E> {
        StringDeserializer(Some(self), PhantomData)
    }
}

#[cfg(any(feature = "std", feature = "collections"))]
impl<E> de::Deserializer for StringDeserializer<E>
    where E: de::Error,
{
    type Error = E;

    fn deserialize<V>(&mut self, mut visitor: V) -> Result<V::Value, Self::Error>
        where V: de::Visitor,
    {
        match self.0.take() {
            Some(string) => visitor.visit_string(string),
            None => Err(de::Error::end_of_stream()),
        }
    }

    fn deserialize_enum<V>(&mut self,
                     _name: &str,
                     _variants: &'static [&'static str],
                     mut visitor: V) -> Result<V::Value, Self::Error>
        where V: de::EnumVisitor,
    {
        visitor.visit(self)
    }

    de_forward_to_deserialize!{
        deserialize_bool,
        deserialize_f64, deserialize_f32,
        deserialize_u8, deserialize_u16, deserialize_u32, deserialize_u64, deserialize_usize,
        deserialize_i8, deserialize_i16, deserialize_i32, deserialize_i64, deserialize_isize,
        deserialize_char, deserialize_str, deserialize_string,
        deserialize_ignored_any,
        deserialize_bytes,
        deserialize_unit_struct, deserialize_unit,
        deserialize_seq, deserialize_seq_fixed_size,
        deserialize_map, deserialize_newtype_struct, deserialize_struct_field,
        deserialize_tuple,
        deserialize_struct, deserialize_tuple_struct,
        deserialize_option
    }
}

#[cfg(any(feature = "std", feature = "collections"))]
impl<'a, E> de::VariantVisitor for StringDeserializer<E>
    where E: de::Error,
{
    type Error = E;

    fn visit_variant<T>(&mut self) -> Result<T, Self::Error>
        where T: de::Deserialize,
    {
        de::Deserialize::deserialize(self)
    }

    fn visit_unit(&mut self) -> Result<(), Self::Error> {
        Ok(())
    }

    fn visit_newtype<T>(&mut self) -> Result<T, Self::Error>
        where T: super::Deserialize,
    {
        let (value,) = try!(self.visit_tuple(1, super::impls::TupleVisitor1::new()));
        Ok(value)
    }

    fn visit_tuple<V>(&mut self,
                      _len: usize,
                      _visitor: V) -> Result<V::Value, Self::Error>
        where V: super::Visitor
    {
        Err(super::Error::invalid_type(super::Type::TupleVariant))
    }

    fn visit_struct<V>(&mut self,
                       _fields: &'static [&'static str],
                       _visitor: V) -> Result<V::Value, Self::Error>
        where V: super::Visitor
    {
        Err(super::Error::invalid_type(super::Type::StructVariant))
    }
}

///////////////////////////////////////////////////////////////////////////////

/// A helper deserializer that deserializes a `String`.
#[cfg(any(feature = "std", feature = "collections"))]
pub struct CowStrDeserializer<'a, E>(Option<Cow<'a, str>>, PhantomData<E>);

#[cfg(any(feature = "std", feature = "collections"))]
impl<'a, E> ValueDeserializer<E> for Cow<'a, str>
    where E: de::Error,
{
    type Deserializer = CowStrDeserializer<'a, E>;

    fn into_deserializer(self) -> CowStrDeserializer<'a, E> {
        CowStrDeserializer(Some(self), PhantomData)
    }
}

#[cfg(any(feature = "std", feature = "collections"))]
impl<'a, E> de::Deserializer for CowStrDeserializer<'a, E>
    where E: de::Error,
{
    type Error = E;

    fn deserialize<V>(&mut self, mut visitor: V) -> Result<V::Value, Self::Error>
        where V: de::Visitor,
    {
        match self.0.take() {
            Some(Cow::Borrowed(string)) => visitor.visit_str(string),
            Some(Cow::Owned(string)) => visitor.visit_string(string),
            None => Err(de::Error::end_of_stream()),
        }
    }

    fn deserialize_enum<V>(&mut self,
                     _name: &str,
                     _variants: &'static [&'static str],
                     mut visitor: V) -> Result<V::Value, Self::Error>
        where V: de::EnumVisitor,
    {
        visitor.visit(self)
    }

    de_forward_to_deserialize!{
        deserialize_bool,
        deserialize_f64, deserialize_f32,
        deserialize_u8, deserialize_u16, deserialize_u32, deserialize_u64, deserialize_usize,
        deserialize_i8, deserialize_i16, deserialize_i32, deserialize_i64, deserialize_isize,
        deserialize_char, deserialize_str, deserialize_string,
        deserialize_ignored_any,
        deserialize_bytes,
        deserialize_unit_struct, deserialize_unit,
        deserialize_seq, deserialize_seq_fixed_size,
        deserialize_map, deserialize_newtype_struct, deserialize_struct_field,
        deserialize_tuple,
        deserialize_struct, deserialize_tuple_struct,
        deserialize_option
    }
}

#[cfg(any(feature = "std", feature = "collections"))]
impl<'a, E> de::VariantVisitor for CowStrDeserializer<'a, E>
    where E: de::Error,
{
    type Error = E;

    fn visit_variant<T>(&mut self) -> Result<T, Self::Error>
        where T: de::Deserialize,
    {
        de::Deserialize::deserialize(self)
    }

    fn visit_unit(&mut self) -> Result<(), Self::Error> {
        Ok(())
    }

    fn visit_newtype<T>(&mut self) -> Result<T, Self::Error>
        where T: super::Deserialize,
    {
        let (value,) = try!(self.visit_tuple(1, super::impls::TupleVisitor1::new()));
        Ok(value)
    }

    fn visit_tuple<V>(&mut self,
                      _len: usize,
                      _visitor: V) -> Result<V::Value, Self::Error>
        where V: super::Visitor
    {
        Err(super::Error::invalid_type(super::Type::TupleVariant))
    }

    fn visit_struct<V>(&mut self,
                       _fields: &'static [&'static str],
                       _visitor: V) -> Result<V::Value, Self::Error>
        where V: super::Visitor
    {
        Err(super::Error::invalid_type(super::Type::StructVariant))
    }
}

///////////////////////////////////////////////////////////////////////////////

/// A helper deserializer that deserializes a sequence.
pub struct SeqDeserializer<I, E> {
    iter: I,
    len: usize,
    marker: PhantomData<E>,
}

impl<I, E> SeqDeserializer<I, E>
    where E: de::Error,
{
    /// Construct a new `SeqDeserializer<I>`.
    pub fn new(iter: I, len: usize) -> Self {
        SeqDeserializer {
            iter: iter,
            len: len,
            marker: PhantomData,
        }
    }
}

impl<I, T, E> de::Deserializer for SeqDeserializer<I, E>
    where I: Iterator<Item=T>,
          T: ValueDeserializer<E>,
          E: de::Error,
{
    type Error = E;

    fn deserialize<V>(&mut self, mut visitor: V) -> Result<V::Value, Self::Error>
        where V: de::Visitor,
    {
        visitor.visit_seq(self)
    }

    de_forward_to_deserialize!{
        deserialize_bool,
        deserialize_f64, deserialize_f32,
        deserialize_u8, deserialize_u16, deserialize_u32, deserialize_u64, deserialize_usize,
        deserialize_i8, deserialize_i16, deserialize_i32, deserialize_i64, deserialize_isize,
        deserialize_char, deserialize_str, deserialize_string,
        deserialize_ignored_any,
        deserialize_bytes,
        deserialize_unit_struct, deserialize_unit,
        deserialize_seq, deserialize_seq_fixed_size,
        deserialize_map, deserialize_newtype_struct, deserialize_struct_field,
        deserialize_tuple,
        deserialize_enum,
        deserialize_struct, deserialize_tuple_struct,
        deserialize_option
    }
}

impl<I, T, E> de::SeqVisitor for SeqDeserializer<I, E>
    where I: Iterator<Item=T>,
          T: ValueDeserializer<E>,
          E: de::Error,
{
    type Error = E;

    fn visit<V>(&mut self) -> Result<Option<V>, Self::Error>
        where V: de::Deserialize
    {
        match self.iter.next() {
            Some(value) => {
                self.len -= 1;
                let mut de = value.into_deserializer();
                Ok(Some(try!(de::Deserialize::deserialize(&mut de))))
            }
            None => Ok(None),
        }
    }

    fn end(&mut self) -> Result<(), Self::Error> {
        if self.len == 0 {
            Ok(())
        } else {
            Err(de::Error::invalid_length(self.len))
        }
    }

    fn size_hint(&self) -> (usize, Option<usize>) {
        (self.len, Some(self.len))
    }
}

///////////////////////////////////////////////////////////////////////////////

#[cfg(any(feature = "std", feature = "collections"))]
impl<T, E> ValueDeserializer<E> for Vec<T>
    where T: ValueDeserializer<E>,
          E: de::Error,
{
    type Deserializer = SeqDeserializer<vec::IntoIter<T>, E>;

    fn into_deserializer(self) -> Self::Deserializer {
        let len = self.len();
        SeqDeserializer::new(self.into_iter(), len)
    }
}

#[cfg(any(feature = "std", feature = "collections"))]
impl<T, E> ValueDeserializer<E> for BTreeSet<T>
    where T: ValueDeserializer<E> + Eq + Ord,
          E: de::Error,
{
    type Deserializer = SeqDeserializer<btree_set::IntoIter<T>, E>;

    fn into_deserializer(self) -> Self::Deserializer {
        let len = self.len();
        SeqDeserializer::new(self.into_iter(), len)
    }
}

#[cfg(feature = "std")]
impl<T, E> ValueDeserializer<E> for HashSet<T>
    where T: ValueDeserializer<E> + Eq + Hash,
          E: de::Error,
{
    type Deserializer = SeqDeserializer<hash_set::IntoIter<T>, E>;

    fn into_deserializer(self) -> Self::Deserializer {
        let len = self.len();
        SeqDeserializer::new(self.into_iter(), len)
    }
}

///////////////////////////////////////////////////////////////////////////////

/// A helper deserializer that deserializes a sequence using a `SeqVisitor`.
pub struct SeqVisitorDeserializer<V_, E> {
    visitor: V_,
    marker: PhantomData<E>,
}

impl<V_, E> SeqVisitorDeserializer<V_, E>
    where V_: de::SeqVisitor<Error = E>,
          E: de::Error,
{
    /// Construct a new `SeqVisitorDeserializer<V_, E>`.
    pub fn new(visitor: V_) -> Self {
        SeqVisitorDeserializer{
            visitor: visitor,
            marker: PhantomData
        }
    }
}

impl<V_, E> de::Deserializer for SeqVisitorDeserializer<V_, E>
    where V_: de::SeqVisitor<Error = E>,
          E: de::Error,
{
    type Error = E;

    fn deserialize<V: de::Visitor>(&mut self, mut visitor: V) -> Result<V::Value, Self::Error> {
        visitor.visit_seq(&mut self.visitor)
    }

    de_forward_to_deserialize!{
        deserialize_bool,
        deserialize_f64, deserialize_f32,
        deserialize_u8, deserialize_u16, deserialize_u32, deserialize_u64, deserialize_usize,
        deserialize_i8, deserialize_i16, deserialize_i32, deserialize_i64, deserialize_isize,
        deserialize_char, deserialize_str, deserialize_string,
        deserialize_ignored_any,
        deserialize_bytes,
        deserialize_unit_struct, deserialize_unit,
        deserialize_seq, deserialize_seq_fixed_size,
        deserialize_map, deserialize_newtype_struct, deserialize_struct_field,
        deserialize_tuple,
        deserialize_enum,
        deserialize_struct, deserialize_tuple_struct,
        deserialize_option
    }
}

///////////////////////////////////////////////////////////////////////////////

/// A helper deserializer that deserializes a map.
pub struct MapDeserializer<I, K, V, E>
    where I: Iterator<Item=(K, V)>,
          K: ValueDeserializer<E>,
          V: ValueDeserializer<E>,
          E: de::Error,
{
    iter: I,
    value: Option<V>,
    len: Option<usize>,
    marker: PhantomData<E>,
}

impl<I, K, V, E> MapDeserializer<I, K, V, E>
    where I: Iterator<Item=(K, V)>,
          K: ValueDeserializer<E>,
          V: ValueDeserializer<E>,
          E: de::Error,
{
    /// Construct a new `MapDeserializer<I, K, V, E>` with a specific length.
    pub fn new(iter: I, len: usize) -> Self {
        MapDeserializer {
            iter: iter,
            value: None,
            len: Some(len),
            marker: PhantomData,
        }
    }

    /// Construct a new `MapDeserializer<I, K, V, E>` that is not bounded
    /// by a specific length and that delegates to `iter` for its size hint.
    pub fn unbounded(iter: I) -> Self {
        MapDeserializer {
            iter: iter,
            value: None,
            len: None,
            marker: PhantomData,
        }
    }
}

impl<I, K, V, E> de::Deserializer for MapDeserializer<I, K, V, E>
    where I: Iterator<Item=(K, V)>,
          K: ValueDeserializer<E>,
          V: ValueDeserializer<E>,
          E: de::Error,
{
    type Error = E;

    fn deserialize<V_>(&mut self, mut visitor: V_) -> Result<V_::Value, Self::Error>
        where V_: de::Visitor,
    {
        visitor.visit_map(self)
    }

    de_forward_to_deserialize!{
        deserialize_bool,
        deserialize_f64, deserialize_f32,
        deserialize_u8, deserialize_u16, deserialize_u32, deserialize_u64, deserialize_usize,
        deserialize_i8, deserialize_i16, deserialize_i32, deserialize_i64, deserialize_isize,
        deserialize_char, deserialize_str, deserialize_string,
        deserialize_ignored_any,
        deserialize_bytes,
        deserialize_unit_struct, deserialize_unit,
        deserialize_seq, deserialize_seq_fixed_size,
        deserialize_map, deserialize_newtype_struct, deserialize_struct_field,
        deserialize_tuple,
        deserialize_enum,
        deserialize_struct, deserialize_tuple_struct,
        deserialize_option
    }
}

impl<I, K, V, E> de::MapVisitor for MapDeserializer<I, K, V, E>
    where I: Iterator<Item=(K, V)>,
          K: ValueDeserializer<E>,
          V: ValueDeserializer<E>,
          E: de::Error,
{
    type Error = E;

    fn visit_key<T>(&mut self) -> Result<Option<T>, Self::Error>
        where T: de::Deserialize,
    {
        match self.iter.next() {
            Some((key, value)) => {
                if let Some(len) = self.len.as_mut() {
                    *len -= 1;
                }
                self.value = Some(value);
                let mut de = key.into_deserializer();
                Ok(Some(try!(de::Deserialize::deserialize(&mut de))))
            }
            None => Ok(None),
        }
    }

    fn visit_value<T>(&mut self) -> Result<T, Self::Error>
        where T: de::Deserialize,
    {
        match self.value.take() {
            Some(value) => {
                let mut de = value.into_deserializer();
                de::Deserialize::deserialize(&mut de)
            }
            None => {
                Err(de::Error::end_of_stream())
            }
        }
    }

    fn end(&mut self) -> Result<(), Self::Error> {
        match self.len {
            Some(len) if len > 0 => Err(de::Error::invalid_length(len)),
            _ => Ok(())
        }
    }

    fn size_hint(&self) -> (usize, Option<usize>) {
        self.len.map_or_else(
            || self.iter.size_hint(),
            |len| (len, Some(len)))
    }
}

///////////////////////////////////////////////////////////////////////////////

#[cfg(any(feature = "std", feature = "collections"))]
impl<K, V, E> ValueDeserializer<E> for BTreeMap<K, V>
    where K: ValueDeserializer<E> + Eq + Ord,
          V: ValueDeserializer<E>,
          E: de::Error,
{
    type Deserializer = MapDeserializer<btree_map::IntoIter<K, V>, K, V, E>;

    fn into_deserializer(self) -> Self::Deserializer {
        let len = self.len();
        MapDeserializer::new(self.into_iter(), len)
    }
}

#[cfg(feature = "std")]
impl<K, V, E> ValueDeserializer<E> for HashMap<K, V>
    where K: ValueDeserializer<E> + Eq + Hash,
          V: ValueDeserializer<E>,
          E: de::Error,
{
    type Deserializer = MapDeserializer<hash_map::IntoIter<K, V>, K, V, E>;

    fn into_deserializer(self) -> Self::Deserializer {
        let len = self.len();
        MapDeserializer::new(self.into_iter(), len)
    }
}

///////////////////////////////////////////////////////////////////////////////

/// A helper deserializer that deserializes a map using a `MapVisitor`.
pub struct MapVisitorDeserializer<V_, E> {
    visitor: V_,
    marker: PhantomData<E>,
}

impl<V_, E> MapVisitorDeserializer<V_, E>
    where V_: de::MapVisitor<Error = E>,
          E: de::Error,
{
    /// Construct a new `MapVisitorDeserializer<V_, E>`.
    pub fn new(visitor: V_) -> Self {
        MapVisitorDeserializer{
            visitor: visitor,
            marker: PhantomData
        }
    }
}

impl<V_, E> de::Deserializer for MapVisitorDeserializer<V_, E>
    where V_: de::MapVisitor<Error = E>,
          E: de::Error,
{
    type Error = E;

    fn deserialize<V: de::Visitor>(&mut self, mut visitor: V) -> Result<V::Value, Self::Error> {
        visitor.visit_map(&mut self.visitor)
    }

    de_forward_to_deserialize!{
        deserialize_bool,
        deserialize_f64, deserialize_f32,
        deserialize_u8, deserialize_u16, deserialize_u32, deserialize_u64, deserialize_usize,
        deserialize_i8, deserialize_i16, deserialize_i32, deserialize_i64, deserialize_isize,
        deserialize_char, deserialize_str, deserialize_string,
        deserialize_ignored_any,
        deserialize_bytes,
        deserialize_unit_struct, deserialize_unit,
        deserialize_seq, deserialize_seq_fixed_size,
        deserialize_map, deserialize_newtype_struct, deserialize_struct_field,
        deserialize_tuple,
        deserialize_enum,
        deserialize_struct, deserialize_tuple_struct,
        deserialize_option
    }
}

///////////////////////////////////////////////////////////////////////////////

impl<'a, E> ValueDeserializer<E> for bytes::Bytes<'a>
    where E: de::Error,
{
    type Deserializer = BytesDeserializer<'a, E>;

    fn into_deserializer(self) -> BytesDeserializer<'a, E> {
        BytesDeserializer(Some(self.into()), PhantomData)
    }
}

/// A helper deserializer that deserializes a `&[u8]`.
pub struct BytesDeserializer<'a, E> (Option<&'a [u8]>, PhantomData<E>);

impl<'a, E> de::Deserializer for BytesDeserializer<'a, E>
    where E: de::Error
{
    type Error = E;

    fn deserialize<V>(&mut self, mut visitor: V) -> Result<V::Value, Self::Error>
        where V: de::Visitor,
    {
        match self.0.take() {
            Some(bytes) => visitor.visit_bytes(bytes),
            None => Err(de::Error::end_of_stream()),
        }
    }

    de_forward_to_deserialize!{
        deserialize_bool,
        deserialize_f64, deserialize_f32,
        deserialize_u8, deserialize_u16, deserialize_u32, deserialize_u64, deserialize_usize,
        deserialize_i8, deserialize_i16, deserialize_i32, deserialize_i64, deserialize_isize,
        deserialize_char, deserialize_str, deserialize_string,
        deserialize_ignored_any,
        deserialize_bytes,
        deserialize_unit_struct, deserialize_unit,
        deserialize_seq, deserialize_seq_fixed_size,
        deserialize_map, deserialize_newtype_struct, deserialize_struct_field,
        deserialize_tuple,
        deserialize_enum,
        deserialize_struct, deserialize_tuple_struct,
        deserialize_option
    }
}


///////////////////////////////////////////////////////////////////////////////

#[cfg(any(feature = "std", feature = "collections"))]
impl<E> ValueDeserializer<E> for bytes::ByteBuf
    where E: de::Error,
{
    type Deserializer = ByteBufDeserializer<E>;

    fn into_deserializer(self) -> Self::Deserializer {
        ByteBufDeserializer(Some(self.into()), PhantomData)
    }
}

/// A helper deserializer that deserializes a `Vec<u8>`.
#[cfg(any(feature = "std", feature = "collections"))]
pub struct ByteBufDeserializer<E>(Option<Vec<u8>>, PhantomData<E>);

#[cfg(any(feature = "std", feature = "collections"))]
impl<E> de::Deserializer for ByteBufDeserializer<E>
    where E: de::Error,
{
    type Error = E;

    fn deserialize<V>(&mut self, mut visitor: V) -> Result<V::Value, Self::Error>
        where V: de::Visitor,
    {
        match self.0.take() {
            Some(bytes) => visitor.visit_byte_buf(bytes),
            None => Err(de::Error::end_of_stream()),
        }
    }

    de_forward_to_deserialize!{
        deserialize_bool,
        deserialize_f64, deserialize_f32,
        deserialize_u8, deserialize_u16, deserialize_u32, deserialize_u64, deserialize_usize,
        deserialize_i8, deserialize_i16, deserialize_i32, deserialize_i64, deserialize_isize,
        deserialize_char, deserialize_str, deserialize_string,
        deserialize_ignored_any,
        deserialize_bytes,
        deserialize_unit_struct, deserialize_unit,
        deserialize_seq, deserialize_seq_fixed_size,
        deserialize_map, deserialize_newtype_struct, deserialize_struct_field,
        deserialize_tuple,
        deserialize_enum,
        deserialize_struct, deserialize_tuple_struct,
        deserialize_option
    }
}
