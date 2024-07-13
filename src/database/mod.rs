use std::env;

use auth::{Account, LoginError, TokenError};
use rocket::time::{Duration, OffsetDateTime};
use sqlx::{postgres::PgPoolOptions, Pool, Postgres};

pub mod auth;
pub mod posts;

// usare sqlx

pub struct User {
    pub id: i32,
    pub name: String,
    pub surname: String,
    pub username: String,
    pub is_admin: bool,
}
impl Default for User {
    fn default() -> Self {
        Self {
            username: String::from("username"),
            id: -1,
            name: String::from("name"),
            surname: String::from("surname"),
            is_admin: false,
        }
    }
}

pub struct AdminUser {
    pub user: User,
}

impl Default for AdminUser {
    fn default() -> Self {
        Self {
            user: User::default(),
        }
    }
}

pub struct DatabaseInstance {
    pool: Pool<Postgres>,
}

impl DatabaseInstance {
    pub async fn new() -> Self {
        let host = env::var("POSTGRES_HOST").expect("mysql_host missing from env");
        let user = env::var("POSTGRES_USER").expect("mysql_user missing from env");
        let password = env::var("POSTGRES_PASSWORD").expect("mysql_password missing from env");
        let db = env::var("POSTGRES_DB").expect("mysql_db missing from env");

        println!("{}", format!("postgres://{user}:{password}@{host}/{db}"));
        let pool = PgPoolOptions::new()
            .max_connections(5)
            .connect(&format!("postgres://{user}:{password}@{host}/{db}"))
            .await
            .unwrap();

        Self { pool }
    }

    pub async fn get_from_session(&self, token: &str) -> Result<Account, TokenError> {
        let maybe_session = sqlx::query!(
            r#"
                SELECT users.user_id, users.is_admin, users.username, users.name, users.surname, sessions.session_start
                FROM users, sessions
                WHERE sessions.token = $1 and users.user_id = sessions.user_id
                LIMIT 1;
            "#r, token)
            .fetch_optional(&self.pool)
            .await
            .unwrap();

        return if let Some(session) = maybe_session {
            if session.session_start + Duration::seconds(3600) > OffsetDateTime::now_utc() {
                let user = User {
                    id: session.user_id,
                    name: session.name,
                    surname: session.surname,
                    username: session.username,
                    is_admin: session.is_admin,
                };
                if session.is_admin {
                    Ok(Account::Admin(AdminUser { user }))
                } else {
                    Ok(Account::User(user))
                }
            } else {
                Err(TokenError::ExpiredSession)
            }
        } else {
            Err(TokenError::NonExistentSession)
        };
    }

    pub async fn login_user<'r>(
        &self,
        username: &str,
        password: &str,
    ) -> Result<String, LoginError> {
        let maybe_result = sqlx::query!(
            r#"
                    SELECT
                        (select user_id from users where username = $1 limit 1) as username_present,
                        (select user_id from users where username = $1 and password = crypt($2, password) limit 1) as user_id
                "#r,
            username,
            password
        )
        .fetch_optional(&self.pool)
        .await
        .unwrap();

        let result = maybe_result.unwrap();

        return if let Some(_) = result.username_present {
            if let Some(user_id) = result.user_id {
                let session = sqlx::query!(
                    r#"
                        WITH new_session AS (
                            INSERT INTO public.sessions (user_id, session_start)
                            VALUES ($1, $2)
                            RETURNING token
                        )
                        SELECT token FROM new_session;
                        "#r,
                    user_id,
                    OffsetDateTime::now_utc()
                )
                .fetch_optional(&self.pool)
                .await
                .unwrap()
                .unwrap();
                Ok(session.token)
            } else {
                Err(LoginError::WrongPassword)
            }
        } else {
            Err(LoginError::NoSuchUser)
        };
    }
}
