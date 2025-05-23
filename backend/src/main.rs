#[macro_use]
extern crate diesel;
#[macro_use]
extern crate diesel_migrations;

use crate::app::AppConfig;
use actix_web::HttpServer;
use actix_web::web::Data;
use diesel::prelude::*;
use diesel::r2d2::{self, ConnectionManager};
use diesel_migrations::{EmbeddedMigrations, MigrationHarness};
use std::env;

mod app;
mod db_options;
mod errors;
mod models;
mod schema;
#[cfg(test)]
pub mod tester;
#[cfg(test)]
mod tests;
mod utils;

use log::info;

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    if env::var("RUST_LOG").is_err() {
        // TODO: Audit that the environment access only happens in single-threaded code.
        unsafe { env::set_var("RUST_LOG", "info") };
    }

    env_logger::init();

    // create the db folder if it doesn't already exist
    std::fs::create_dir_all("db").expect("failed creating db folder");

    // set up database connection pool
    let manager = ConnectionManager::<SqliteConnection>::new("db/db.sqlite");
    let pool = r2d2::Pool::builder()
        .connection_customizer(Box::new(db_options::ConnectionOptions {
            enable_foreign_keys: false,
            busy_timeout: Some(std::time::Duration::from_secs(30)),
        }))
        .build(manager)
        .expect("failed to create pool.");
    pub const MIGRATIONS: EmbeddedMigrations = embed_migrations!("db/migrations");
    pool.get()
        .expect("couldn't get db connection from pool")
        .run_pending_migrations(MIGRATIONS)
        .expect("couldn't run migrations");

    // Set up authorization token
    let app_config = AppConfig::new(env::var("TOKEN").unwrap_or_else(|_| -> String {
        let token = crate::utils::random_string();
        info!("Authorization token: {}", token);
        token
    }));

    // Data should be constructed outside the HttpServer::new closure if shared, potentially mutable state is desired...
    let app_data = Data::new(app_config);

    let bind = "0.0.0.0:8080";

    // Start HTTP server
    HttpServer::new(move || create_app!(pool, &app_data))
        .bind(&bind)?
        .run()
        .await
}
