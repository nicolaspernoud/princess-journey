table! {
    fasting_periods (id) {
        id -> Integer,
        user_id -> Integer,
        start -> Text,
        duration -> Integer,
        closed -> Bool,
    }
}

table! {
    users (id) {
        id -> Integer,
        gender -> Integer,
        height -> Integer,
        target_weight -> Double,
        daily_water_target -> Double,
    }
}

table! {
    water_intakes (id) {
        id -> Integer,
        user_id -> Integer,
        date -> Text,
        value -> Double,
    }
}

table! {
    weights (id) {
        id -> Integer,
        user_id -> Integer,
        date -> Text,
        value -> Double,
    }
}

joinable!(fasting_periods -> users (user_id));
joinable!(water_intakes -> users (user_id));
joinable!(weights -> users (user_id));

allow_tables_to_appear_in_same_query!(fasting_periods, users, water_intakes, weights,);
