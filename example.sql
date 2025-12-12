/* 
  查询语句
*/

-- 建表语句
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    region TEXT NOT NULL,         -- 地区，如 'Asia'
    product TEXT NOT NULL,        -- 产品名称
    order_date DATE NOT NULL,     -- 订单日期
    sales NUMERIC(12,2) NOT NULL  -- 销售额
);

-- 插入示例数据
INSERT INTO orders (region, product, order_date, sales) VALUES
('Asia', 'Laptop',  '2025-01-05', 1500.00),
('Asia', 'Laptop',  '2025-01-18', 1200.00),
('Asia', 'Phone',   '2025-01-20', 800.00),
('Asia', 'Phone',   '2025-02-10', 950.00),
('Asia', 'Tablet',  '2025-02-14', 500.00),

('Europe', 'Laptop', '2025-01-03', 1800.00),
('Europe', 'Phone',  '2025-01-07', 1000.00),
('Europe', 'Tablet', '2025-02-08', 700.00),
('Europe', 'Tablet', '2025-02-20', 600.00),

('America', 'Laptop', '2025-01-15', 2000.00),
('America', 'Phone',  '2025-01-22', 900.00),
('America', 'Laptop', '2025-02-12', 2100.00),
('America', 'Tablet', '2025-02-18', 400.00);
