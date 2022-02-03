use serde::{Deserialize, Serialize};

use crate::{
    crud_create, crud_delete, crud_delete_all, crud_read, crud_read_all, crud_update, crud_use,
    models::user::User, schema::weights,
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
#[table_name = "weights"]
#[belongs_to(User)]
pub struct Weight {
    pub id: i32,
    pub user_id: i32,
    pub date: String,
    pub value: f64,
}

#[derive(Debug, Clone, Deserialize, Insertable, Associations)]
#[table_name = "weights"]
#[belongs_to(User)]
pub struct InWeight {
    pub user_id: i32,
    pub date: String,
    pub value: f64,
}

crud_use!();

crud_create!(InWeight, Weight, weights, User, users, user_id);
crud_read_all!(Weight, weights);
crud_read!(Weight, weights);
crud_update!(Weight, weights, User, users, user_id);
crud_delete!(Weight, weights);
crud_delete_all!(Weight, weights);
