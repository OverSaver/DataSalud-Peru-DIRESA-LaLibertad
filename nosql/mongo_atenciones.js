// ============================================================
// ARCHIVO: mongo_atenciones.js
// DESCRIPCIÓN: Operaciones CRUD y Agregaciones en MongoDB
// ============================================================

use DataSaludNoSQL;

// 1. Insertar Documento en la Colección
db.atenciones_planificacion.insertOne({
  "anio": 2024,
  "departamento": "LA LIBERTAD",
  "provincia": "TRUJILLO",
  "distrito": "TRUJILLO",
  "ubigeo": "130101",
  "estrategia_pf": "CONSEJERIA EN PLANIFICACION FAMILIAR",
  "insumo": "CONDON MASCULINO",
  "cantidad": 12,
  "consejeria": true,
  "fecha_registro": new Date()
});

// 2. Consulta con Filtro por Ubigeo y Estrategia
db.atenciones_planificacion.find({
  "ubigeo": "130101",
  "consejeria": true
});

// 3. Pipeline de Agregación: Total Insumos por Distrito
db.atenciones_planificacion.aggregate([
  { $match: { "departamento": "LA LIBERTAD" } },
  { $group: {
      _id: "$distrito",
      totalInsumos: { $sum: "$cantidad" },
      totalAtenciones: { $sum: 1 }
    }
  },
  { $sort: { totalInsumos: -1 } }
]);
