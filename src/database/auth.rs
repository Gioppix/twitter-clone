use super::{AdminUser, User};
use rocket::{
    http::Status,
    request::{FromRequest, Outcome},
    Request, State,
};

#[derive(Debug)]
pub enum LoginError {
    WrongPassword,
    NoSuchUser,
}

#[derive(Debug)]
pub enum TokenError {
    NoToken,
    NonExistentSession,
    ExpiredSession,
    WrongRole,
}

pub enum Account {
    Admin(AdminUser),
    User(User),
}

#[rocket::async_trait]
impl<'r> FromRequest<'r> for AdminUser {
    type Error = TokenError;

    async fn from_request(req: &'r Request<'_>) -> Outcome<Self, Self::Error> {
        let db = req.rocket().state::<super::DatabaseInstance>().unwrap();

        match req.cookies().get("token") {
            None => Outcome::Forward(Status::Unauthorized),
            Some(cookie) => match db.get_from_session(cookie.value()).await {
                Ok(Account::Admin(admin)) => Outcome::Success(admin),
                Ok(_) => Outcome::Forward(Status::Unauthorized),
                Err(_error) => Outcome::Forward(Status::Unauthorized),
            },
        }
    }
}

#[rocket::async_trait]
impl<'r> FromRequest<'r> for User {
    type Error = TokenError;

    async fn from_request(req: &'r Request<'_>) -> Outcome<Self, Self::Error> {
        let db = req.rocket().state::<super::DatabaseInstance>().unwrap();

        match req.cookies().get("token") {
            None => Outcome::Forward(Status::Unauthorized),
            Some(cookie) => match db.get_from_session(cookie.value()).await {
                Ok(Account::Admin(admin)) => Outcome::Success(admin.user),
                Ok(Account::User(user)) => Outcome::Success(user),
                Err(_error) => Outcome::Forward(Status::Unauthorized),
            },
        }
    }
}
