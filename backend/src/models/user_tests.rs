use crate::{app::AppConfig, create_app};

pub async fn user_test(
    pool: &r2d2::Pool<diesel::r2d2::ConnectionManager<diesel::SqliteConnection>>,
    app_config: AppConfig,
) {
    use crate::{do_test, do_test_extract_id};
    use actix_web::{
        http::{Method, StatusCode},
        test,
    };

    let mut app = test::init_service(create_app!(pool, app_config)).await;

    // Delete all the users
    let req = test::TestRequest::delete()
        .header("Authorization", "Bearer 0101")
        .uri("/api/users")
        .to_request();
    test::call_service(&mut app, req).await;

    // Create a user
    let id = do_test_extract_id!(
        app,
        Method::POST,
        "/api/users",
        r#"{"_gender": 2, "_height": 170, "_targetWeight": 55.0, "_dailyWaterTarget": 1000.0}"#,
        StatusCode::CREATED,
        "{\"id\""
    );

    // Get a user
    do_test!(
        app,
        Method::GET,
        &format!("/api/users/{}", id),
        "",
        StatusCode::OK,
        format!(
            r#"{{"id":{id},"_gender":2,"_height":170,"_targetWeight":55.0,"_dailyWaterTarget":1000.0,"_weights":[],"_waterIntakes":[],"_fastingPeriods":[]}}"#
        )
    );

    // Get a non existing user
    do_test!(
        app,
        Method::GET,
        &format!("/api/users/{}", id + 1),
        "",
        StatusCode::NOT_FOUND,
        "\"Could not get user: NotFound\""
    );

    // Patch the user
    do_test!(
        app,
        Method::PUT,
        &format!("/api/users/{}", id),
        &format!(
            r#"{{"id": {id}, "_gender": 2, "_height": 170, "_targetWeight": 57.0, "_dailyWaterTarget": 1000.0}}"#
        ),
        StatusCode::OK,
        &format!(
            r#"{{"id":{id},"_gender":2,"_height":170,"_targetWeight":57.0,"_dailyWaterTarget":1000.0}}"#
        )
    );

    // Add two weights
    let idw1 = do_test_extract_id!(
        app,
        Method::POST,
        &format!("/api/weights"),
        &format!(r#"{{"user_id":{id},"date":"2022-02-06T00:00:00.000","value":60.0}}"#),
        StatusCode::CREATED,
        r#"{"id":"#
    );
    let idw2 = do_test_extract_id!(
        app,
        Method::POST,
        &format!("/api/weights"),
        &format!(r#"{{"user_id":{id},"date":"2022-02-16T00:00:00.000","value":57.0}}"#),
        StatusCode::CREATED,
        r#"{"id":"#
    );

    // Add two water intakes
    let idwi1 = do_test_extract_id!(
        app,
        Method::POST,
        &format!("/api/water_intakes"),
        &format!(r#"{{"user_id":{id},"date":"2022-02-06T00:00:00.000","value":100.0}}"#),
        StatusCode::CREATED,
        r#"{"id":"#
    );
    let idwi2 = do_test_extract_id!(
        app,
        Method::POST,
        &format!("/api/water_intakes"),
        &format!(r#"{{"user_id":{id},"date":"2022-02-07T00:00:00.000","value":200.0}}"#),
        StatusCode::CREATED,
        r#"{"id":"#
    );

    // Add two fasting periods
    let idfp1 = do_test_extract_id!(
        app,
        Method::POST,
        &format!("/api/fasting_periods"),
        &format!(
            r#"{{"user_id":{id},"start":"2022-02-06T13:32:52.899630","duration":12,"closed":false}}"#
        ),
        StatusCode::CREATED,
        r#"{"id":"#
    );
    let idfp2 = do_test_extract_id!(
        app,
        Method::POST,
        &format!("/api/fasting_periods"),
        &format!(
            r#"{{"user_id":{id},"start":"2022-02-07T13:32:52.899630","duration":12,"closed":false}}"#
        ),
        StatusCode::CREATED,
        r#"{"id":"#
    );

    // Get the user with the associated data
    do_test!(
        app,
        Method::GET,
        &format!("/api/users/{}", id),
        "",
        StatusCode::OK,
        format!(
            r#"{{"id":{id},"_gender":2,"_height":170,"_targetWeight":57.0,"_dailyWaterTarget":1000.0,"_weights":[{{"id":{idw1},"user_id":{id},"date":"2022-02-06T00:00:00.000","value":60.0}},{{"id":{idw2},"user_id":{id},"date":"2022-02-16T00:00:00.000","value":57.0}}],"_waterIntakes":[{{"id":{idwi1},"user_id":{id},"date":"2022-02-06T00:00:00.000","value":100.0}},{{"id":{idwi2},"user_id":{id},"date":"2022-02-07T00:00:00.000","value":200.0}}],"_fastingPeriods":[{{"id":{idfp1},"user_id":{id},"start":"2022-02-06T13:32:52.899630","duration":12,"closed":false}},{{"id":{idfp2},"user_id":{id},"start":"2022-02-07T13:32:52.899630","duration":12,"closed":false}}]}}"#
        )
    );

    // Test that we can get the associated objects individualy
    do_test!(
        app,
        Method::GET,
        &format!("/api/weights/{idw1}"),
        "",
        StatusCode::OK,
        format!(r#"{{"id":{idw1},"user_id":{id},"date":"2022-02-06T00:00:00.000","value":60.0}}"#)
    );
    do_test!(
        app,
        Method::GET,
        &format!("/api/water_intakes/{idwi1}"),
        "",
        StatusCode::OK,
        format!(
            r#"{{"id":{idwi1},"user_id":{id},"date":"2022-02-06T00:00:00.000","value":100.0}}"#
        )
    );
    do_test!(
        app,
        Method::GET,
        &format!("/api/fasting_periods/{idfp1}"),
        "",
        StatusCode::OK,
        format!(
            r#"{{"id":{idfp1},"user_id":{id},"start":"2022-02-06T13:32:52.899630","duration":12,"closed":false}}"#
        )
    );

    // Delete the user
    do_test!(
        app,
        Method::DELETE,
        &format!("/api/users/{}", id),
        "",
        StatusCode::OK,
        format!("Deleted object with id: {}", id)
    );

    // Test that cascade delete worked correctly
    do_test!(
        app,
        Method::GET,
        &format!("/api/weights/{idw1}"),
        "",
        StatusCode::NOT_FOUND,
        "Object not found"
    );
    do_test!(
        app,
        Method::GET,
        &format!("/api/water_intakes/{idwi1}"),
        "",
        StatusCode::NOT_FOUND,
        "Object not found"
    );
    do_test!(
        app,
        Method::GET,
        &format!("/api/fasting_periods/{idfp1}"),
        "",
        StatusCode::NOT_FOUND,
        "Object not found"
    );

    // Delete a non existing user
    do_test!(
        app,
        Method::DELETE,
        &format!("/api/users/{}", id + 1),
        "",
        StatusCode::NOT_FOUND,
        "Object not found"
    );

    // Delete all the users
    let req = test::TestRequest::delete()
        .header("Authorization", "Bearer 0101")
        .uri("/api/users")
        .to_request();
    test::call_service(&mut app, req).await;

    // Create two users and get them all
    let id1 = do_test_extract_id!(
        app,
        Method::POST,
        "/api/users",
        r#"{"_gender": 2, "_height": 140, "_targetWeight": 45, "_dailyWaterTarget": 1000.0}"#,
        StatusCode::CREATED,
        "{\"id\""
    );
    let id2 = do_test_extract_id!(
        app,
        Method::POST,
        "/api/users",
        r#"{"_gender": 2, "_height": 160, "_targetWeight": 56.0, "_dailyWaterTarget": 1000.0}"#,
        StatusCode::CREATED,
        "{\"id\""
    );
    do_test!(
        app,
        Method::GET,
        "/api/users",
        "",
        StatusCode::OK,
        format!(
            r#"[{{"id":{id1},"_gender":2,"_height":140,"_targetWeight":45.0,"_dailyWaterTarget":1000.0}},{{"id":{id2},"_gender":2,"_height":160,"_targetWeight":56.0,"_dailyWaterTarget":1000.0}}]"#
        )
    );

    // Delete all the users
    do_test!(
        app,
        Method::DELETE,
        "/api/users",
        "",
        StatusCode::OK,
        "Deleted all objects"
    );
}
