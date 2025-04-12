module main

import veb
import db.sqlite

pub struct User {
pub mut:
	name string
	id   int
}

// Our context struct must embed `veb.Context`!
pub struct Context {
	veb.Context
pub mut:
	// In the context struct we store data that could be different
	// for each request. Like a User struct or a session id
	user       User
	session_id string
}

pub struct App {
pub:
	// In the app struct we store data that should be accessible by all endpoints.
	// For example, a database or configuration values.
	secret_key string
	ip         string
	db         sqlite.DB
}

// This is how endpoints are defined in veb. This is the index route
pub fn (app &App) index(mut ctx Context) veb.Result {
	apptitle := 'V-lang Web App'
	return $veb.html('index.html')
}

pub fn (app &App) categories(mut ctx Context) veb.Result {
	mut res := app.db.exec_map('Select * from categories') or { panic(err) }
	return $veb.html('categories.html')
}

@['/products/:catid'; get]
pub fn (app &App) products(mut ctx Context, catid string) veb.Result {
	mut res := app.db.exec_map("Select * from products Where categoryid='${catid}'") or {
		panic(err)
	}
	return $veb.html('products.html')
}

pub fn (app &App) customers(mut ctx Context) veb.Result {
	mut res := app.db.exec_map('Select * from customers') or { panic(err) }
	return $veb.html('customers.html')
}

@['/orders/:custid'; get]
pub fn (app &App) orders(mut ctx Context, custid string) veb.Result {
	mut res := app.db.exec_map("Select orderid, strftime('%d-%m-%Y',orderdate) orderdate, strftime('%d-%m-%Y', shippeddate) shippeddate from orders where customerid='${custid}'") or {
		panic(err)
	}
	return $veb.html('orders.html')
}

@['/orderdetails/:orderid/:custid'; get]
pub fn (app &App) orderdetails(mut ctx Context, orderid string, custid string) veb.Result {
	mut res := app.db.exec_map('Select od.orderid, p.productname, od.quantity, od.unitprice from orderdetails od Join products p on p.productid = od.productid where od.orderid= ${orderid}') or {
		panic(err)
	}
	return $veb.html('orderdetails')
}

pub fn (app &App) clock(mut ctx Context) veb.Result {
	return $veb.html('clock')
}

pub fn (app &App) contact(mut ctx Context) veb.Result {
	return $veb.html('contact')
}

fn main() {
	mut app := &App{
		secret_key: 's3crEt'
		db:         sqlite.connect('northwindlite.db') or { panic(err) }
	}
	// Pass the App and context type and start the web server on port 8080
	veb.run[App, Context](mut app, 8080)
}
