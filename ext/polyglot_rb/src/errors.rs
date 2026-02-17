use magnus::{Error, ExceptionClass, Module, Ruby};
use std::cell::RefCell;

thread_local! {
    static POLYGLOT_ERROR: RefCell<Option<ExceptionClass>> = const { RefCell::new(None) };
    static PARSE_ERROR: RefCell<Option<ExceptionClass>> = const { RefCell::new(None) };
    static GENERATE_ERROR: RefCell<Option<ExceptionClass>> = const { RefCell::new(None) };
    static UNSUPPORTED_ERROR: RefCell<Option<ExceptionClass>> = const { RefCell::new(None) };
}

pub fn define_exceptions(ruby: &Ruby, module: &magnus::RModule) -> Result<(), Error> {
    let standard_error = ruby.exception_standard_error();

    let polyglot_error = module.define_error("Error", standard_error)?;
    POLYGLOT_ERROR.with(|cell| {
        *cell.borrow_mut() = Some(polyglot_error);
    });

    let parse_error = module.define_error("ParseError", polyglot_error)?;
    PARSE_ERROR.with(|cell| {
        *cell.borrow_mut() = Some(parse_error);
    });

    let generate_error = module.define_error("GenerateError", polyglot_error)?;
    GENERATE_ERROR.with(|cell| {
        *cell.borrow_mut() = Some(generate_error);
    });

    let unsupported_error = module.define_error("UnsupportedError", polyglot_error)?;
    UNSUPPORTED_ERROR.with(|cell| {
        *cell.borrow_mut() = Some(unsupported_error);
    });

    Ok(())
}

pub fn polyglot_error(message: String) -> Error {
    POLYGLOT_ERROR.with(|cell| {
        let class = cell.borrow();
        match class.as_ref() {
            Some(cls) => Error::new(*cls, message),
            None => {
                let ruby = Ruby::get().expect("Ruby runtime not available");
                Error::new(ruby.exception_runtime_error(), message)
            }
        }
    })
}

pub fn parse_error(message: String) -> Error {
    PARSE_ERROR.with(|cell| {
        let class = cell.borrow();
        match class.as_ref() {
            Some(cls) => Error::new(*cls, message),
            None => {
                let ruby = Ruby::get().expect("Ruby runtime not available");
                Error::new(ruby.exception_runtime_error(), message)
            }
        }
    })
}

pub fn generate_error(message: String) -> Error {
    GENERATE_ERROR.with(|cell| {
        let class = cell.borrow();
        match class.as_ref() {
            Some(cls) => Error::new(*cls, message),
            None => {
                let ruby = Ruby::get().expect("Ruby runtime not available");
                Error::new(ruby.exception_runtime_error(), message)
            }
        }
    })
}

pub fn unsupported_error(message: String) -> Error {
    UNSUPPORTED_ERROR.with(|cell| {
        let class = cell.borrow();
        match class.as_ref() {
            Some(cls) => Error::new(*cls, message),
            None => {
                let ruby = Ruby::get().expect("Ruby runtime not available");
                Error::new(ruby.exception_runtime_error(), message)
            }
        }
    })
}

pub fn map_polyglot_error(err: polyglot_sql::error::Error) -> Error {
    let message = err.to_string();

    match err {
        polyglot_sql::error::Error::Parse(..) => parse_error(message),
        polyglot_sql::error::Error::Tokenize { .. } => parse_error(message),
        polyglot_sql::error::Error::Syntax { .. } => parse_error(message),
        polyglot_sql::error::Error::Generate(..) => generate_error(message),
        polyglot_sql::error::Error::Unsupported { .. } => unsupported_error(message),
        polyglot_sql::error::Error::Internal(..) => polyglot_error(message),
    }
}
