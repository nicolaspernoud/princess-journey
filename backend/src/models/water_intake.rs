use serde::{Deserialize, Serialize};

use crate::{
    crud_create, crud_delete, crud_delete_all, crud_read, crud_read_all, crud_update, crud_use,
    models::user::User, schema::water_intakes,
};

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
#[table_name = "water_intakes"]
#[belongs_to(User)]
pub struct WaterIntake {
    pub id: i32,
    pub user_id: i32,
    pub date: String,
    pub value: f64,
}

#[derive(Debug, Clone, Deserialize, Insertable, Associations)]
#[table_name = "water_intakes"]
#[belongs_to(User)]
pub struct InWaterIntake {
    pub user_id: i32,
    pub date: String,
    pub value: f64,
}

crud_use!();

crud_create!(
    InWaterIntake,
    WaterIntake,
    water_intakes,
    User,
    users,
    user_id
);
crud_read_all!(WaterIntake, water_intakes);
crud_read!(WaterIntake, water_intakes);
crud_update!(WaterIntake, water_intakes, User, users, user_id);
crud_delete!(WaterIntake, water_intakes);
crud_delete_all!(WaterIntake, water_intakes);
