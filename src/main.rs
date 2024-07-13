pub mod database;
pub mod pages;
pub mod router;

const BASE_URL: &str = "http://localhost:8000";

use rocket::launch;
use router::init;

#[launch]
async fn rocket() -> _ {
    init().await
}
