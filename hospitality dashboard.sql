use hospitality;
DELIMITER $$

CREATE PROCEDURE HospitalityDashboard()
BEGIN
    -- 1. Total Revenue
    SELECT 
        SUM(revenue_generated) AS Total_Revenue 
    FROM fact_bookings;

    -- 2. Occupancy
    SELECT 
        ROUND((SUM(successful_bookings) / SUM(capacity)) * 100, 2) AS Occupancy_Percentage
    FROM fact_aggregated_bookings;

    -- 3. Cancellation Rate
    SELECT 
        ROUND((SUM(CASE WHEN booking_status = 'Cancelled' THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) AS Cancellation_Rate
    FROM fact_bookings;

    -- 4. Total Booking
    SELECT 
        COUNT(booking_id) AS Total_Bookings
    FROM fact_bookings;

    -- 5. Utilized Capacity
    SELECT 
        property_id, check_in_date,
        ROUND((successful_bookings / capacity) * 100, 2) AS Utilized_Capacity_Percentage
    FROM fact_aggregated_bookings;

    -- 6. Trend Analysis
    SELECT 
        DATE(check_in_date) AS Date,
        SUM(revenue_generated) AS Daily_Revenue,
        COUNT(booking_id) AS Daily_Bookings
    FROM fact_bookings
    GROUP BY DATE(check_in_date)
    ORDER BY Date;

    -- 7. Weekday & Weekend Revenue and Booking
    SELECT 
        dd.day_type,
        SUM(fb.revenue_generated) AS Revenue,
        COUNT(fb.booking_id) AS Bookings
    FROM fact_bookings fb
    JOIN dim_date dd ON fb.check_in_date = dd.date
    GROUP BY dd.day_type;



    -- 8. Revenue by State & Hotel
    SELECT 
        dh.city AS State,
        dh.property_name AS Hotel,
        SUM(fb.revenue_generated) AS Revenue
    FROM fact_bookings fb
    JOIN dim_hotels dh ON fb.property_id = dh.property_id
    GROUP BY State, Hotel;

    -- 9. Class-wise Revenue
    SELECT 
        dr.room_class,
        SUM(fb.revenue_generated) AS Revenue
    FROM fact_bookings fb
    JOIN dim_rooms dr ON fb.room_category = dr.room_id
    GROUP BY dr.room_class;

    -- 10. Checked-out, Canceled, No-show Data
    SELECT 
        booking_status,
        COUNT(*) AS Count
    FROM fact_bookings
    GROUP BY booking_status;
    
    -- 11. Weekly Key Trends
    SELECT 
    WEEK(dd.date, 1) AS Week_Number, -- Calculate the ISO week number dynamically
    SUM(fb.revenue_generated) AS Weekly_Revenue,
    COUNT(fb.booking_id) AS Weekly_Bookings,
    ROUND((SUM(fa.successful_bookings) / SUM(fa.capacity)) * 100, 2) AS Weekly_Occupancy
FROM fact_bookings fb
JOIN dim_date dd 
    ON fb.check_in_date = dd.date -- Join to match the date
JOIN fact_aggregated_bookings fa 
    ON fb.property_id = fa.property_id AND fb.check_in_date = fa.check_in_date -- Join for occupancy details
GROUP BY WEEK(dd.date, 1)
ORDER BY Week_Number;

END$$

DELIMITER ;

CALL HospitalityDashboard()