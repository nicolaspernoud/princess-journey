use actix_web::error::{self};
use actix_web::{dev::ServiceRequest, Error};
use actix_web_httpauth::extractors::bearer::BearerAuth;

#[derive(Clone)]
pub struct AppConfig {
    pub bearer_token: String,
}

impl AppConfig {
    pub fn new(token: String) -> Self {
        AppConfig {
            bearer_token: token,
        }
    }
}

pub async fn validator(
    req: ServiceRequest,
    credentials: BearerAuth,
) -> Result<ServiceRequest, Error> {
    let app_config = req
        .app_data::<actix_web::web::Data<AppConfig>>()
        .expect("Could not get token configuration");
    if app_config.bearer_token == credentials.token() {
        Ok(req)
    } else {
        Err(error::ErrorUnauthorized("Wrong token!"))
    }
}

#[macro_export]
macro_rules! create_app {
    ($pool:expr, $app_config:expr) => {{
        use crate::models::{fasting_period, user, water_intake, weight};
        use actix_cors::Cors;
        use actix_web::{error, middleware, web, web::Data, App, HttpResponse};
        use actix_web_httpauth::middleware::HttpAuthentication;

        App::new()
            .app_data(Data::new($pool.clone()))
            .app_data(
                web::JsonConfig::default()
                    .limit(4096)
                    .error_handler(|err, _req| {
                        error::InternalError::from_response(err, HttpResponse::Conflict().finish())
                            .into()
                    }),
            )
            .app_data(web::Data::new($app_config))
            .wrap(Cors::permissive())
            .wrap(middleware::Logger::default())
            .service(
                web::scope("/api/users")
                    .wrap(HttpAuthentication::bearer(crate::app::validator))
                    .service(user::read_all)
                    .service(user::read)
                    .service(user::create)
                    .service(user::update)
                    .service(user::delete_all)
                    .service(user::delete),
            )
            .service(
                web::scope("/api/weights")
                    .wrap(HttpAuthentication::bearer(crate::app::validator))
                    .service(weight::read_all)
                    .service(weight::read)
                    .service(weight::create)
                    .service(weight::update)
                    .service(weight::delete_all)
                    .service(weight::delete),
            )
            .service(
                web::scope("/api/water_intakes")
                    .wrap(HttpAuthentication::bearer(crate::app::validator))
                    .service(water_intake::read_all)
                    .service(water_intake::read)
                    .service(water_intake::create)
                    .service(water_intake::update)
                    .service(water_intake::delete_all)
                    .service(water_intake::delete),
            )
            .service(
                web::scope("/api/fasting_periods")
                    .wrap(HttpAuthentication::bearer(crate::app::validator))
                    .service(fasting_period::read_all)
                    .service(fasting_period::read)
                    .service(fasting_period::create)
                    .service(fasting_period::update)
                    .service(fasting_period::delete_all)
                    .service(fasting_period::delete),
            )
            .service(actix_files::Files::new("/", "./web").index_file("index.html"))
    }};
}
