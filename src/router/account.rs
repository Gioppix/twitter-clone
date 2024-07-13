use crate::database::DatabaseInstance;
use crate::database::User;
use crate::pages::LoginPage;
use askama::Template;
use maud::html;
use maud::Markup;
use rocket::form::Form;
use rocket::response::{content, Redirect};
use rocket::State;
use rocket::{get, http::CookieJar};
use rocket::{post, uri, FromForm};

#[get("/login")]
pub async fn login_page() -> content::RawHtml<String> {
    content::RawHtml(LoginPage::new(None).render().unwrap())
}

#[derive(FromForm)]
pub struct Login<'r> {
    username: &'r str,
    password: &'r str,
}

#[post("/login", data = "<login>")]
pub async fn post_login(
    jar: &CookieJar<'_>,
    login: Form<Login<'_>>,
    db: &State<DatabaseInstance>,
) -> Result<Redirect, content::RawHtml<String>> {
    let res = db.login_user(login.username, login.password).await;

    return match res {
        Ok(s) => {
            jar.add(("token", s));
            Ok(Redirect::to(uri!("/")))
        }
        Err(err) => Err(content::RawHtml(
            LoginPage::new(Some(format!("{:?}", err).as_str()))
                .render()
                .unwrap(),
        )),
    };
}

#[get("/logout")]
pub fn logout(jar: &CookieJar<'_>, user: Option<User>) -> Result<Redirect, Markup> {
    return match user {
        Some(_) => {
            jar.remove("token");
            Ok(Redirect::to(uri!("/")))
        }
        None => Err(html!("No current session")),
    };
}
