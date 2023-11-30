create table Hotel
( hotel_id serial primary key,
  name text not null,
  location text not null,
  price_per_night numeric not null
  );

create table Customer
(
  customer_id serial primary key,
  first_name text not null,
  last_name text not null,
  email text,
  phone text not null
  );

create table Tour
(
  tour_id serial primary key,
  destination text not null,
  departure_date date not null,
  return_date date not null,
  price numeric not null
);

create table Booking
(
  booking_id serial primary key,
  customer_id bigint not null,
  constraint fk_booking_customer_id foreign key (customer_id) references Customer(customer_id),
  tour_id bigint not null,
  constraint fk_booking_tour_id foreign key (tour_id) references Tour(tour_id),
  hotel_id bigint not null,
  constraint fk_booking_hotel_id foreign key (hotel_id) references Hotel(hotel_id),
  check_in_date date not null,
  check_out_date date not null,
  star_rating numeric not null 
);

ALTER SEQUENCE public.customer_customer_id_seq RESTART WITH 101;
ALTER SEQUENCE public.hotel_hotel_id_seq RESTART WITH 201;
alter table Booking add constraint rating_range check ( star_rating between 0 and 5);

create table CustomerTour
(
    custom_tour_id serial primary key,
    customer_id bigint not null,
    constraint fk_customer_tour_customer_id foreign key (customer_id) references Customer(customer_id),
    tour_id bigint not null,
    constraint fk_customer_tour_tour_id foreign key (tour_id) references Tour(tour_id)
);
INSERT INTO Hotel (name, location, price_per_night) 
VALUES 
('Hotel Paris', 'Paris', 200.00),
('Luxury Rome Hotel', 'Rome', 250.00),
('Tokyo Tower Hotel', 'Tokyo', 180.00),
('New York Plaza Hotel', 'New York', 220.00),
('Sydney Harbour Hotel', 'Sydney', 190.00);

INSERT INTO Customer (first_name, last_name, email, phone) 
VALUES 
('John', 'Doe', 'johndoe@example.com', '123-456-7890'),
('Jane', 'Smith', 'janesmith@example.com', '456-789-0123'),
('Michael', 'Johnson', 'michaeljohnson@example.com', '789-012-3456'),
('Emily', 'Davis', 'emilydavis@example.com', '012-345-6789'),
('William', 'Brown', 'williambrown@example.com', '345-678-9012');

INSERT INTO Tour (destination, departure_date, return_date, price) 
VALUES 
('Paris', '2022-07-15', '2022-07-22', 1500.00),
('Rome', '2022-08-10', '2022-08-17', 1700.00),
('Tokyo', '2022-09-05', '2022-09-12', 2000.00),
('New York', '2022-10-20', '2022-10-27', 1800.00),
('Sydney', '2022-11-15', '2022-11-22', 1900.00);

INSERT INTO Booking (customer_id, tour_id, hotel_id, check_in_date, check_out_date, star_rating) 
VALUES 
(101, 1, 201, '2022-07-15', '2022-07-22', 4),
(102, 2, 202, '2022-08-10', '2022-08-17', 5),
(103, 3, 203, '2022-09-05', '2022-09-12', 4),
(104, 4, 204, '2022-10-20', '2022-10-27', 3),
(105, 5, 205, '2022-11-15', '2022-11-22', 4);

INSERT INTO CustomerTour (customer_id, tour_id) 
VALUES 
(101, 1),
(102, 2),
(103, 3),
(104, 4),
(105, 5);
