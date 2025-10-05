import { writeFileSync } from "fs";
import { Trino } from "trino-client";

// Подключение к Trino
const client = Trino.create({
  host: "http://localhost:8080", // обязательно http://
  catalog: "e_commerce",
  schema: "ecommerce",
  user: "user",
});

// Тестовые запросы разной сложности
const queries = [
  {
    name: "Все активные пользователи",
    sql: "SELECT * FROM users WHERE is_active = true",
  },
  {
    name: "Продукты electronics",
    sql: "SELECT * FROM products WHERE category = 'electronics'",
  },
  {
    name: "Заказы с суммой > 100",
    sql: "SELECT * FROM orders WHERE total_amount > 100",
  },
  {
    name: "Заказы с JOIN пользователей",
    sql: `
      SELECT o.order_id, o.total_amount, u.name AS user_name
      FROM orders o
      JOIN users u ON o.user_id = u.user_id
    `,
  },
  {
    name: "Заказы с JOIN продуктов и order_items",
    sql: `
      SELECT oi.order_item_id, oi.quantity, p.product_name, o.order_date
      FROM order_items oi
      JOIN products p ON oi.product_id = p.product_id
      JOIN orders o ON oi.order_id = o.order_id
    `,
  },
  {
    name: "Сумма заказов по категории продуктов",
    sql: `
      SELECT p.category, SUM(oi.unit_price * oi.quantity) AS total_sales
      FROM order_items oi
      JOIN products p ON oi.product_id = p.product_id
      JOIN orders o ON oi.order_id = o.order_id
      GROUP BY p.category
      ORDER BY total_sales DESC
    `,
  },
];

// Функция для выполнения запроса и получения всех данных
const runQuery = async (query) => {
  const start = Date.now();
  const iterator = await client.query(query.sql);

  // Собираем все строки в массив
  const rows = [];
  for await (const row of iterator) {
    if (row.data) {
      rows.push(...row.data);
    }
  }

  const duration = Date.now() - start;
  console.log(`${query.name}: ${rows.length} rows, executed in ${duration} ms`);
  // Пример: первые 3 строки
  console.log("Sample rows:", rows.slice(0, 3));

  return { name: query.name, rows: rows.length, duration, data: rows };
};

// Основная функция тестирования
async function main() {
  const results = [];

  for (const query of queries) {
    try {
      const res = await runQuery(query);
      results.push(res);
    } catch (err) {
      console.error("Error running query", query.name, err);
    }
  }

  // Сохраняем результаты в CSV
  const csv = results
    .map((r) => `${r.name},${r.rows},${r.duration}`)
    .join("\n");
  writeFileSync("trino_test_results.csv", "Query,Rows,Duration_ms\n" + csv);
  console.log("Results saved to trino_test_results.csv");
}

main();
