use askama::Template;
use rocket::time::OffsetDateTime;

use super::{DatabaseInstance, User};

pub struct TextPost {
    pub post_id: i32,
    pub author: User,
    pub created_at: OffsetDateTime,
    pub content: String,
    pub editable: bool,
    pub maybe_comments: Option<Vec<Comment>>,
}

#[derive(Template, Clone, Debug)]
#[template(path = "comment.html", escape = "none")]
pub struct Comment {
    pub comment_id: i32,
    pub commenter_username: String,
    pub text: String,
    pub created_at: OffsetDateTime,
    pub replies: Vec<Comment>,
    referenced_comment_id: Option<i32>,
    post_id: i32,
}

#[derive(Debug)]
pub enum PostCreationError {
    OtherError,
    Empty,
}

#[derive(Debug)]
pub enum CommentCreationError {
    OtherError,
    Empty,
    InvalidContext,
}

impl DatabaseInstance {
    pub async fn get_posts(&self, author_filter: Option<(i32, bool)>) -> Vec<TextPost> {
        let filter_not_empty = author_filter.is_some();
        let (author, filter) = author_filter.unwrap_or((0, false));
        let posts = sqlx::query!(
            r#"
                SELECT *, (u.user_id = $1 and $3) as editable FROM posts p, users u WHERE p.author = u.user_id and ((u.user_id = $1 and $2) or not $2) ORDER BY created_at DESC LIMIT 100 ;
            "#r,
            author,
            filter,
            filter_not_empty
        )
        .fetch_all(&self.pool)
        .await
        .unwrap();

        posts
            .iter()
            .map(|post| TextPost {
                author: User {
                    id: post.user_id,
                    name: post.name.clone(),
                    surname: post.surname.clone(),
                    username: post.username.clone(),
                    is_admin: post.is_admin,
                },
                content: post.content.clone(),
                created_at: post.created_at,
                post_id: post.post_id,
                editable: post.editable.unwrap(),
                maybe_comments: None,
            })
            .collect()
    }

    pub async fn get_post(&self, post_id: i32, user: Option<&User>) -> Option<TextPost> {
        let post = sqlx::query!(
            r#"
                SELECT * FROM posts p, users u WHERE p.author = u.user_id and p.post_id = $1 LIMIT 1;
            "#r,
            post_id
        )
        .fetch_optional(&self.pool)
        .await
        .unwrap();

        let comments = self.get_comments(post_id).await;

        post.map(|post| TextPost {
            author: User {
                id: post.user_id,
                name: post.name.clone(),
                surname: post.surname.clone(),
                username: post.username.clone(),
                is_admin: post.is_admin,
            },
            content: post.content.clone(),
            created_at: post.created_at,
            post_id: post.post_id,
            editable: user.map_or(false, |u| u.id == post.author),
            maybe_comments: Some(comments),
        })
    }

    pub async fn get_comments(&self, post_id: i32) -> Vec<Comment> {
        let comments_raw = sqlx::query!(
            r#"
                WITH RECURSIVE answers AS (select *
                                        from comments
                                        where referenced_post_id = $1

                                        UNION ALL

                                        select c.*
                                        from comments c,
                                                answers a
                                        where c.referenced_comment_id = a.comment_id)

                SELECT *
                from answers, users
                where users.user_id = answers.commenter
                order by comment_id desc
            "#r,
            post_id
        )
        .fetch_all(&self.pool)
        .await
        .unwrap();

        let mut comments: Vec<Comment> = vec![];

        comments_raw.into_iter().for_each(|el| {
            let mut comment = Comment {
                post_id,
                comment_id: el.comment_id.unwrap(),
                commenter_username: el.username,
                created_at: el.created_at.unwrap(),
                text: el.text.unwrap(),
                referenced_comment_id: el.referenced_comment_id,
                replies: vec![],
            };

            let replies: Vec<Comment> = comments
                .iter()
                .rev()
                .filter(|c| c.referenced_comment_id == Some(comment.comment_id))
                .cloned()
                .collect();
            comments.retain(|c| c.referenced_comment_id != Some(comment.comment_id));
            comment.replies = replies;
            comments.push(comment);
        });

        comments //.into_iter().rev().collect()
    }

    pub async fn create_post(
        &self,
        user_id: i32,
        content: String,
    ) -> Result<TextPost, PostCreationError> {
        if content.len() == 0 {
            return Err(PostCreationError::Empty);
        }

        let maybe_post = sqlx::query!(
            r#"
                WITH new_post AS (
                    INSERT INTO posts (author, content)
                    VALUES ($1, $2)
                    RETURNING *
                )
                SELECT * FROM new_post p, users u where p.author = u.user_id;
            "#r,
            user_id,
            content
        )
        .fetch_optional(&self.pool)
        .await
        .unwrap();
        if let Some(post) = maybe_post {
            Ok(TextPost {
                author: User {
                    id: post.user_id,
                    name: post.name,
                    surname: post.surname,
                    username: post.username,
                    is_admin: post.is_admin,
                },
                content: post.content,
                created_at: post.created_at,
                post_id: post.post_id,
                editable: false,
                maybe_comments: None,
            })
        } else {
            Err(PostCreationError::OtherError)
        }
    }

    pub async fn create_comment(
        &self,
        user_id: i32,
        text: String,
        referenced_post_id: Option<i32>,
        referenced_comment_id: Option<i32>,
    ) -> Result<(), CommentCreationError> {
        if text.len() == 0 {
            return Err(CommentCreationError::Empty);
        }
        if referenced_post_id.is_some() && referenced_comment_id.is_some()
            || referenced_post_id.is_none() && referenced_comment_id.is_none()
        {
            return Err(CommentCreationError::InvalidContext);
        }

        let maybe_comment = sqlx::query!(
            r#"
                WITH new_comment AS (
                    INSERT INTO comments (referenced_post_id, referenced_comment_id, text, commenter)
                    VALUES ($1, $2, $3, $4)
                    RETURNING *
                )
                SELECT * FROM new_comment;
            "#r,
            referenced_post_id,
            referenced_comment_id,
            text,
            user_id
        )
        .fetch_optional(&self.pool)
        .await
        .unwrap();
        if let Some(_) = maybe_comment {
            Ok(())
        } else {
            Err(CommentCreationError::OtherError)
        }
    }
}
