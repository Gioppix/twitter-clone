mod account;
mod middleware;
pub mod posts;
use crate::database::{AdminUser, DatabaseInstance, User};
use crate::pages::{AdminPanel, HelloTemplate, HomePage};
use askama::Template;
use maud::{html, Markup};
use middleware::{CountStorage, Counter};
use rocket::data::{Data, ToByteUnit};
use rocket::response::{content, Redirect};
use rocket::State;
use rocket::{get, post, routes, Build, Rocket};
use rocket::{tokio, uri};
use std::sync::{Arc, RwLock};
use std::time::Instant;

#[post("/button")]
fn button() -> Markup {
    html!(
        h3 { (format!("lol {:?}", Instant::now())) }
    )
}

#[get("/time")]
fn time() -> Markup {
    html!((format!("{:?}", Instant::now())))
}

// use crate::pages

// #[get("/")]
// fn admin_home(admin: AdminUser) -> content::RawHtml<String> {
//     let page = HomePage::new(format!("{} (Admin)", admin.user.username), true);
//     let rendered = page.render().unwrap();
//     content::RawHtml(rendered)
// }
#[get("/", rank = 2)]
async fn user_home(user: User, db: &State<DatabaseInstance>) -> content::RawHtml<String> {
    let posts = db.get_posts(None).await;
    let page = HomePage::new(user, posts, true);
    let rendered = page.render().unwrap();
    content::RawHtml(rendered)
}

#[get("/", rank = 3)]
fn guest_home() -> Redirect {
    Redirect::to(uri!(account::login_page))
    // let page = HelloTemplate::new(user.username.to_string());
    // let rendered = page.render().unwrap();
    // content::RawHtml(rendered)
}

#[get("/admin")]
fn admin_panel(
    _admin: AdminUser,
    hit_count: &State<Arc<RwLock<CountStorage>>>,
) -> content::RawHtml<String> {
    content::RawHtml(
        AdminPanel::new(
            true,
            hit_count.read().unwrap().get_get_count(),
            hit_count.read().unwrap().get_post_count(),
        )
        .render()
        .unwrap(),
    )
}

#[get("/hello")]
async fn hello() -> content::RawHtml<String> {
    content::RawHtml(
        HelloTemplate::new("Gio".to_string(), false)
            .render()
            .unwrap(),
    )
}

#[post("/debug", data = "<data>")]
async fn debug(data: Data<'_>) -> std::io::Result<()> {
    // Stream at most 512KiB all of the body data to stdout.
    data.open(512.kibibytes())
        .stream_to(tokio::io::stdout())
        .await?;

    Ok(())
}

pub async fn init() -> Rocket<Build> {
    let counter = Counter::new();
    rocket::build()
        .mount(
            "/",
            routes![
                user_home,
                guest_home,
                debug,
                button,
                time,
                account::login_page,
                account::post_login,
                account::logout,
                posts::see_post,
                posts::create_post,
                posts::create_post_page,
                posts::create_comment,
                admin_panel,
                hello,
                // admin_home
            ],
        )
        .manage(counter.get_storage())
        .manage(DatabaseInstance::new().await)
        .attach(counter)
}
