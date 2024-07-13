use std::sync::atomic::{AtomicUsize, Ordering};
use std::sync::{Arc, RwLock};

use rocket::fairing::{Fairing, Info, Kind};
use rocket::http::Method;
use rocket::{Data, Request};

pub struct CountStorage {
    get: AtomicUsize,
    post: AtomicUsize,
}

impl CountStorage {
    pub fn get_get_count(&self) -> usize {
        self.get.load(Ordering::Relaxed)
    }

    pub fn get_post_count(&self) -> usize {
        self.post.load(Ordering::Relaxed)
    }

    pub fn incr_get_count(&mut self) {
        self.get.fetch_add(1, Ordering::Relaxed);
    }

    pub fn incr_post_count(&mut self) {
        self.post.fetch_add(1, Ordering::Relaxed);
    }

    pub fn new() -> Self {
        Self {
            get: AtomicUsize::new(0),
            post: AtomicUsize::new(0),
        }
    }
}

pub struct Counter {
    storage: Arc<RwLock<CountStorage>>,
}
// Arc<RwLock<CountStorage>>
impl Counter {
    pub fn new() -> Self {
        Self {
            storage: Arc::new(RwLock::new(CountStorage::new())),
        }
    }
    pub fn get_storage(&self) -> Arc<RwLock<CountStorage>> {
        self.storage.clone()
    }
}

#[rocket::async_trait]
impl Fairing for Counter {
    fn info(&self) -> Info {
        Info {
            name: "GET/POST Counter",
            kind: Kind::Request | Kind::Response,
        }
    }

    async fn on_request(&self, request: &mut Request<'_>, _: &mut Data<'_>) {
        match request.method() {
            Method::Get => self.storage.write().unwrap().incr_get_count(),
            Method::Post => self.storage.write().unwrap().incr_post_count(),
            _ => return,
        };
    }
}
