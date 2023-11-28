create table Hotel
( hotel_id bigint primary key,
  name text not null,
  location text not null,
  price_per_night numeric not null
  );

create table Customer
(
  customer_id bigint primary key,
  first_name text not null,
  last_name text not null,
  email text,
  phone text not null
  );

create table Tour
(
  tour_id bigint primary key,
  destination text not null,
  departure_date date not null,
  return_date date not null,
  price numeric not null
);

create table Booking
(
  booking_id bigint primary key,
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

alter table Booking add constraint rating_range check ( star_rating between 0 and 5);

create table CustomerTour
(
    custom_tour_id bigint primary key,
    customer_id bigint not null,
    constraint fk_customer_tour_customer_id foreign key (customer_id) references Customer(customer_id),
    tour_id bigint not null,
    constraint fk_customer_tour_tour_id foreign key (tour_id) references Tour(tour_id)
);
INSERT INTO Hotel (hotel_id, name, location, price_per_night) 
VALUES 
(201, 'Hotel Paris', 'Paris', 200.00),
(202, 'Luxury Rome Hotel', 'Rome', 250.00),
(203, 'Tokyo Tower Hotel', 'Tokyo', 180.00),
(204, 'New York Plaza Hotel', 'New York', 220.00),
(205, 'Sydney Harbour Hotel', 'Sydney', 190.00);

INSERT INTO Customer (customer_id, first_name, last_name, email, phone) 
VALUES 
(101, 'John', 'Doe', 'johndoe@example.com', '123-456-7890'),
(102, 'Jane', 'Smith', 'janesmith@example.com', '456-789-0123'),
(103, 'Michael', 'Johnson', 'michaeljohnson@example.com', '789-012-3456'),
(104, 'Emily', 'Davis', 'emilydavis@example.com', '012-345-6789'),
(105, 'William', 'Brown', 'williambrown@example.com', '345-678-9012');

INSERT INTO Tour (tour_id, destination, departure_date, return_date, price) 
VALUES 
(1, 'Paris', '2022-07-15', '2022-07-22', 1500.00),
(2, 'Rome', '2022-08-10', '2022-08-17', 1700.00),
(3, 'Tokyo', '2022-09-05', '2022-09-12', 2000.00),
(4, 'New York', '2022-10-20', '2022-10-27', 1800.00),
(5, 'Sydney', '2022-11-15', '2022-11-22', 1900.00);

INSERT INTO Booking (booking_id, customer_id, tour_id, hotel_id, check_in_date, check_out_date, star_rating) 
VALUES 
(1, 101, 1, 201, '2022-07-15', '2022-07-22', 4),
(2, 102, 2, 202, '2022-08-10', '2022-08-17', 5),
(3, 103, 3, 203, '2022-09-05', '2022-09-12', 4),
(4, 104, 4, 204, '2022-10-20', '2022-10-27', 3),
(5, 105, 5, 205, '2022-11-15', '2022-11-22', 4);

INSERT INTO CustomerTour (custom_tour_id, customer_id, tour_id) 
VALUES 
(1, 101, 1),
(2, 102, 2),
(3, 103, 3),
(4, 104, 4),
(5, 105, 5);