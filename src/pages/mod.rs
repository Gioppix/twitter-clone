use askama::Template;
use rocket::{time::OffsetDateTime, uri};

use crate::database::posts::Comment;
use crate::database::{posts::TextPost, User};
use crate::router::posts::rocket_uri_macro_see_post;

fn print_date(date: &OffsetDateTime) -> String {
    format!("{} {} {}", date.day(), date.month(), date.year())
}

#[derive(Template)]
#[template(path = "hello.html")]
pub struct HelloTemplate {
    name: String,
    is_admin: bool,
}

impl HelloTemplate {
    pub fn new(name: String, is_admin: bool) -> Self {
        Self { name, is_admin }
    }
}

#[derive(Template)]
#[template(path = "login.html")]
pub struct LoginPage<'a> {
    message: Option<&'a str>,
}

impl<'a> LoginPage<'a> {
    pub fn new(message: Option<&'a str>) -> Self {
        Self { message }
    }
}

// #[derive(Template)]
// #[template(path = "comment.html")]
// struct CommentTempl {
//     comment: Comment,
// }

#[derive(Template)]
#[template(path = "home.html")]
pub struct HomePage {
    user: User,
    posts: Vec<TextPost>,
    is_admin: bool,
}
impl HomePage {
    pub fn new(user: User, posts: Vec<TextPost>, is_admin: bool) -> Self {
        Self {
            user,
            posts,
            is_admin,
        }
    }
}

#[derive(Template)]
#[template(path = "my-posts.html")]
pub struct MyPostsPage {
    user: User,
    posts: Vec<TextPost>,
    is_admin: bool,
}
impl MyPostsPage {
    pub fn new(user: User, posts: Vec<TextPost>, is_admin: bool) -> Self {
        Self {
            user,
            posts,
            is_admin,
        }
    }
}

#[derive(Template)]
#[template(path = "single-post.html")]
pub struct SinglePostPage {
    post: TextPost,
    is_admin: bool,
}
impl SinglePostPage {
    pub fn new(post: TextPost, is_admin: bool) -> Self {
        Self { is_admin, post }
    }
}

#[derive(Template)]
#[template(path = "comments.html")]
pub struct CommentsBlock {
    comments: Vec<Comment>,
    post_id: i32,
}

impl CommentsBlock {
    pub fn new(comments: Vec<Comment>, post_id: i32) -> Self {
        Self { comments, post_id }
    }
}

impl TextPost {
    pub fn generate_post_url(&self) -> String {
        uri!(see_post(self.post_id)).to_string()
    }
}

#[derive(Template)]
#[template(path = "new-post.html")]
pub struct NewPostPage {
    is_admin: bool,
    error: Option<String>,
}
impl NewPostPage {
    pub fn new(is_admin: bool, error: Option<String>) -> Self {
        Self { is_admin, error }
    }
}

#[derive(Template)]
#[template(path = "admin-panel.html")]
pub struct AdminPanel {
    is_admin: bool,
    get_hit_count: usize,
    post_hit_count: usize,
}
impl AdminPanel {
    pub fn new(is_admin: bool, get_hit_count: usize, post_hit_count: usize) -> Self {
        Self {
            is_admin,
            get_hit_count,
            post_hit_count,
        }
    }
}
