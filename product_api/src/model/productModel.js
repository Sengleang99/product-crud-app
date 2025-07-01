const db = require("../config/db");

class Product {
  static async getAll() {
    const [rows] = await db.query("SELECT * FROM products");
    return rows;
  }

  static async getById(id) {
    const [rows] = await db.query(
      "SELECT * FROM products WHERE id = ?",
      [id]
    );
    return rows[0];
  }
  static async create(product) {
    const { name, price, stock } = product;
    const [result] = await db.query(
      "INSERT INTO products (name, price, stock) VALUES (?, ?, ?)",
      [name, price, stock]
    );
    return { id: result.insertId, ...product };
  }

  static async update(id, product) {
    const { name, price, stock } = product;
    await db.query(
      "UPDATE products SET name = ?, price = ?, stock = ? WHERE id = ?",
      [name, price, stock, id]
    );
    return { id: id, ...product };
  }

  static async delete(id) {
    await db.query("DELETE FROM products WHERE id = ?", [id]);
    return { message: "Product deleted successfully" };
  }
}

module.exports = Product;
