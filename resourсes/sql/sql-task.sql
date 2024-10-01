--1.Вывести к каждому самолету класс обслуживания и количество мест этого класса
SELECT aircrafts.model, seats.fare_conditions, COUNT(seats.seat_no) AS seat_count FROM seats
JOIN aircrafts USING(aircraft_code)
GROUP BY aircrafts.model, seats.fare_conditions;


--2.Найти 3 самых вместительных самолета (модель + кол-во мест)
SELECT aircrafts.model, COUNT(seats.seat_no) AS seat_count FROM aircrafts
JOIN seats USING(aircraft_code)
GROUP BY aircrafts.model
ORDER BY seat_count DESC
LIMIT 3;


--3.Найти все рейсы, которые задерживались более 2 часов
SELECT *, (actual_departure - scheduled_departure) AS delay FROM flights
WHERE (actual_departure - scheduled_departure) > INTERVAL '2 hours'
ORDER BY delay;


--4.Найти последние 10 билетов, купленные в бизнес-классе (fare_conditions = 'Business'), с указанием имени пассажира и контактных данных
SELECT tickets.passenger_name, tickets.contact_data, ticket_flights.fare_conditions, bookings.book_date FROM tickets
JOIN ticket_flights USING(ticket_no)
JOIN bookings USING(book_ref)
WHERE ticket_flights.fare_conditions = 'Business'
ORDER BY bookings.book_date DESC
LIMIT 10;


--5.Найти все рейсы, у которых нет забронированных мест в бизнес-классе (fare_conditions = 'Business')
SELECT * FROM flights
LEFT JOIN ticket_flights ON flights.flight_id = ticket_flights.flight_id AND ticket_flights.fare_conditions = 'Business'
WHERE ticket_flights.ticket_no IS NULL;



--6.Получить список аэропортов (airport_name) и городов (city), в которых есть рейсы с задержкой по вылету
SELECT DISTINCT airports.airport_name, airports.city FROM airports
JOIN flights ON flights.departure_airport = airports.airport_code
WHERE actual_departure > scheduled_departure;


--7.Получить список аэропортов (airport_name) и количество рейсов, вылетающих из каждого аэропорта, отсортированный по убыванию количества рейсов
SELECT airports.airport_name, COUNT(flights.flight_id) AS flight_count FROM flights
JOIN airports ON flights.departure_airport = airports.airport_code
GROUP BY airports.airport_name
ORDER BY flight_count DESC;


--8.Найти все рейсы, у которых запланированное время прибытия (scheduled_arrival) было изменено и новое время прибытия (actual_arrival) не совпадает с запланированным
SELECT flight_no, scheduled_arrival, actual_arrival FROM flights
WHERE actual_arrival IS NOT NULL AND actual_arrival != scheduled_arrival;


--9.Вывести код, модель самолета и места не эконом класса для самолета "Аэробус A321-200" с сортировкой по местам
SELECT aircrafts.aircraft_code, aircrafts.model, seats.seat_no, seats.fare_conditions FROM aircrafts
JOIN seats USING(aircraft_code)
WHERE aircrafts.model = 'Аэробус A321-200' AND seats.fare_conditions != 'Economy'
ORDER BY seats.seat_no;

--10.Вывести города, в которых больше 1 аэропорта (код аэропорта, аэропорт, город)
SELECT airport_code, airport_name, city FROM airports
WHERE city IN (SELECT city FROM airports GROUP BY city HAVING COUNT(airport_code) > 1);


--11.Найти пассажиров, у которых суммарная стоимость бронирований превышает среднюю сумму всех бронирований
SELECT tickets.passenger_name, SUM(bookings.total_amount) AS total_amount FROM tickets
JOIN bookings USING(book_ref)
GROUP BY tickets.passenger_name
HAVING SUM(bookings.total_amount) > (SELECT AVG(total_amount) FROM bookings);

--12.Найти ближайший вылетающий рейс из Екатеринбурга в Москву, на который еще не завершилась регистрация
SELECT flights.flight_no, flights.status, flights.scheduled_departure, departure_airports.city AS departure_city, arrival_airports.city AS arrival_city FROM flights
JOIN airports AS departure_airports ON flights.departure_airport = departure_airports.airport_code
JOIN airports AS arrival_airports ON flights.arrival_airport = arrival_airports.airport_code
WHERE departure_airports.city = 'Екатеринбург' AND arrival_airports.city = 'Москва' AND flights.scheduled_departure > bookings.now()
	AND flights.status IN('Scheduled', 'Delayed', 'On Time')
ORDER BY flights.scheduled_departure ASC
LIMIT 1;

--13.Вывести самый дешевый и дорогой билет и стоимость (в одном результирующем ответе)
(SELECT tickets.ticket_no, SUM(ticket_flights.amount) AS price FROM tickets
 JOIN ticket_flights ON tickets.ticket_no = ticket_flights.ticket_no
 GROUP BY tickets.ticket_no
 ORDER BY price ASC
 LIMIT 1)
UNION
(SELECT tickets.ticket_no, SUM(ticket_flights.amount) AS price FROM tickets
 JOIN ticket_flights ON tickets.ticket_no = ticket_flights.ticket_no
 GROUP BY tickets.ticket_no
 ORDER BY price DESC
 LIMIT 1);


--14.Написать DDL таблицы Customers, должны быть поля id, firstName, LastName, email, phone. Добавить ограничения на поля (constraints)
CREATE TABLE public.customers (
    id SERIAL PRIMARY KEY,
    firstName VARCHAR(50) NOT NULL,
    lastName VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(15) UNIQUE NOT NULL
);


--15.Написать DDL таблицы Orders, должен быть id, customerId, quantity. Должен быть внешний ключ на таблицу customers + constraints
CREATE TABLE public.orders (
    id SERIAL PRIMARY KEY,
    customerId INT NOT NULL,
    quantity INT CHECK (quantity > 0),
    FOREIGN KEY (customerId) REFERENCES Customers(id)
);


--16.Написать 5 insert в эти таблицы
INSERT INTO Customers (firstName, lastName, email, phone)
VALUES
('Ivan', 'Ivanov', 'ivan.ivanov@mail.com', '21156432'),
('Petr', 'Petrov', 'petr.petrov@mail.com', '213244'),
('Sergey', 'Sergeev', 'sergey.sergeev@mail.com', '121546'),
('Anna', 'Ivanova', 'anna.ivanova@mail.com', '212346549'),
('Elena', 'Sidorova', 'elena.sidorova@mail.com', '21448925');

INSERT INTO Orders (customerId, quantity)
VALUES
(1, 3),
(2, 1),
(3, 2),
(4, 5),
(5, 4);

--17.Удалить таблицы
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Customers;
