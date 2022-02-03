use serde::{Deserialize, Serialize};

use crate::{
    crud_create, crud_delete, crud_delete_all, crud_read_all, crud_update, crud_use, schema::users,
};

use super::{fasting_period::FastingPeriod, water_intake::WaterIntake, weight::Weight};

#[derive(
    Debug,
    Clone,
    Serialize,
    Deserialize,
    Queryable,
    Insertable,
    AsChangeset,
    Identifiable,
    Associations,
)]
#[table_name = "users"]
pub struct User {
    pub id: i32,
    #[serde(rename = "_gender")]
    pub gender: i32,
    #[serde(rename = "_height")]
    pub height: i32,
    #[serde(rename = "_targetWeight")]
    pub target_weight: f64,
    #[serde(rename = "_dailyWaterTarget")]
    pub daily_water_target: f64,
}

#[derive(Debug, Clone, Deserialize, Insertable)]
#[table_name = "users"]
pub struct InUser {
    #[serde(rename = "_gender")]
    pub gender: i32,
    #[serde(rename = "_height")]
    pub height: i32,
    #[serde(rename = "_targetWeight")]
    pub target_weight: f64,
    #[serde(rename = "_dailyWaterTarget")]
    pub daily_water_target: f64,
}

#[derive(Serialize, Debug)]
struct OutUser {
    #[serde(flatten)]
    user: User,
    #[serde(rename = "_weights")]
    weights: Vec<Weight>,
    #[serde(rename = "_waterIntakes")]
    water_intakes: Vec<WaterIntake>,
    #[serde(rename = "_fastingPeriods")]
    fasting_periods: Vec<FastingPeriod>,
}

crud_use!();
crud_create!(InUser, User, users,);
crud_read_all!(User, users);
crud_update!(User, users,);
crud_delete!(User, users);
crud_delete_all!(User, users);

#[get("/{oid}")]
pub async fn read(
    pool: web::Data<DbPool>,
    oid: web::Path<i32>,
) -> Result<HttpResponse, ServerError> {
    let conn = pool.get()?;
    let object = web::block(move || {
        let u: Result<User, diesel::result::Error> =
            users::table.filter(users::id.eq(*oid)).first(&conn);
        let u = match u {
            Ok(r) => r,
            Err(e) => {
                return Err(format!("Could not get user: {e}"));
            }
        };
        let weights = <Weight>::belonging_to(&u).load(&conn);
        let weights = match weights {
            Ok(r) => r,
            Err(e) => {
                return Err(format!("Could not get weights for user: {e}"));
            }
        };
        let fasting_periods = <FastingPeriod>::belonging_to(&u).load(&conn);
        let fasting_periods = match fasting_periods {
            Ok(r) => r,
            Err(e) => {
                return Err(format!("Could not get fasting periods for user: {e}"));
            }
        };
        let water_intakes = <WaterIntake>::belonging_to(&u).load(&conn);
        let water_intakes = match water_intakes {
            Ok(r) => r,
            Err(e) => {
                return Err(format!("Could not get water intakes for user: {e}"));
            }
        };
        Ok(OutUser {
            user: u,
            weights: weights,
            fasting_periods: fasting_periods,
            water_intakes: water_intakes,
        })
    })
    .await?;
    log::debug!("Fetched object: {:?}", object);
    Ok(HttpResponse::Ok().json(object))
}
