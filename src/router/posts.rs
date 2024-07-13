use crate::database::DatabaseInstance;
use crate::database::User;
use crate::pages::CommentsBlock;
use crate::pages::HelloTemplate;
use crate::pages::LoginPage;
use crate::pages::NewPostPage;
use crate::pages::SinglePostPage;
use askama::Template;
use maud::html;
use maud::Markup;
use rocket::form::Form;
use rocket::form::Strict;
use rocket::response::{content, Redirect};
use rocket::State;
use rocket::{get, http::CookieJar};
use rocket::{post, uri, FromForm};

#[derive(FromForm)]
pub struct NewPost {
    content: String,
}
#[derive(FromForm)]
pub struct NewComment {
    text: String,
    post_id: i32,
    referenced_post_id: Option<i32>,
    referenced_comment_id: Option<i32>,
}

#[post("/comment", data = "<new_comment>")]
pub async fn create_comment(
    user: User,
    new_comment: Form<Strict<NewComment>>,
    db: &State<DatabaseInstance>,
) -> Result<content::RawHtml<String>, content::RawHtml<String>> {
    let res = db
        .create_comment(
            user.id,
            html_escape::encode_text(&new_comment.text).into_owned(),
            new_comment.referenced_post_id,
            new_comment.referenced_comment_id,
        )
        .await;

    return match res {
        Ok(_) => Ok(content::RawHtml(
            CommentsBlock::new(
                db.get_comments(new_comment.post_id).await,
                new_comment.post_id,
            )
            .render()
            .unwrap(),
        )),
        Err(err) => Err(content::RawHtml(
            NewPostPage::new(user.is_admin, Some(format!("Error: {:?}", err)))
                .render()
                .unwrap(),
        )),
    };
}

#[get("/new")]
pub fn create_post_page(user: User) -> content::RawHtml<String> {
    content::RawHtml(NewPostPage::new(user.is_admin, None).render().unwrap())
}

#[post("/post", data = "<new_post>")]
pub async fn create_post(
    user: User,
    new_post: Form<NewPost>,
    db: &State<DatabaseInstance>,
) -> Result<Redirect, content::RawHtml<String>> {
    let res = db
        .create_post(
            user.id,
            html_escape::encode_text(&new_post.content).into_owned(),
        )
        .await;

    return match res {
        Ok(post) => Ok(Redirect::to(uri!(see_post(post.post_id)))),
        Err(err) => Err(content::RawHtml(
            NewPostPage::new(user.is_admin, Some(format!("Error: {:?}", err)))
                .render()
                .unwrap(),
        )),
    };
}

#[get("/post/<post_id>")]
pub async fn see_post(
    user: User,
    post_id: i32,
    db: &State<DatabaseInstance>,
) -> content::RawHtml<String> {
    let m_post = db.get_post(post_id, Some(&user)).await;

    match m_post {
        Some(post) => content::RawHtml(SinglePostPage::new(post, false).render().unwrap()),
        None => content::RawHtml(
            HelloTemplate::new("lol".to_string(), false)
                .render()
                .unwrap(),
        ),
    }
}
