use serde::{Deserialize, Serialize};

use crate::{
    crud_create, crud_delete, crud_delete_all, crud_read, crud_read_all, crud_update, crud_use,
    models::user::User, schema::fasting_periods,
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
#[diesel(table_name = fasting_periods)]
#[diesel(belongs_to(User))]
pub struct FastingPeriod {
    pub id: i32,
    pub user_id: i32,
    pub start: String,
    pub duration: i32,
    pub closed: bool,
}

#[derive(Debug, Clone, Deserialize, Insertable, Associations)]
#[diesel(table_name = fasting_periods)]
#[diesel(belongs_to(User))]
pub struct InFastingPeriod {
    pub user_id: i32,
    pub start: String,
    pub duration: i32,
    pub closed: bool,
}

crud_use!();
crud_create!(
    InFastingPeriod,
    FastingPeriod,
    fasting_periods,
    User,
    users,
    user_id
);
crud_read_all!(FastingPeriod, fasting_periods);
crud_read!(FastingPeriod, fasting_periods);
crud_update!(FastingPeriod, fasting_periods, User, users, user_id);
crud_delete!(FastingPeriod, fasting_periods);
crud_delete_all!(FastingPeriod, fasting_periods);
