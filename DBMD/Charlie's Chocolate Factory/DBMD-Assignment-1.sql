CREATE TABLE product (
    product_id INT IDENTITY (1, 1) PRIMARY KEY,
    product_name VARCHAR (225) NOT NULL,
    quantity_on_hand INT
);

CREATE TABLE supplier (
    supplier_id INT IDENTITY (1, 1) PRIMARY KEY,
    supplier_name VARCHAR (255) NOT NULL,
    activation_status INT 
);

CREATE TABLE component (
    component_id INT IDENTITY (1, 1) PRIMARY KEY,
    component_name VARCHAR (255) NOT NULL,
    [description] VARCHAR (255),
    quantity_on_hand INT
);

CREATE TABLE product_stock (
    component_id INT,
    product_id INT,
    PRIMARY KEY (component_id, product_id),
    FOREIGN KEY (component_id)
    REFERENCES component (component_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (product_id)
    REFERENCES product (product_id)
    ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE component_detail (
    component_id INT, 
    supplier_id INT, 
    when_supplied DATE NOT NULL,
    how_much_supplied INT,
    PRIMARY KEY (component_id, supplier_id),
    FOREIGN KEY (component_id)
    REFERENCES component (component_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (supplier_id)
    REFERENCES supplier (supplier_id)
    ON DELETE CASCADE ON UPDATE CASCADE
);