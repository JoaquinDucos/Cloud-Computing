from flask import Flask, request, jsonify
from flask_cors import CORS
import psycopg2

app = Flask(__name__)
CORS(app)  # Habilita CORS para que S3 pueda hacer fetch

# Reemplazá con tus datos reales de RDS
conn = psycopg2.connect(
    host="database-recetas.cxyvhaududjt.us-east-1.rds.amazonaws.com",
    database="db-recetify",
    user="adminrecetas",
    password="recetasrecetas"
)
cursor = conn.cursor()

@app.route("/registro", methods=["POST"])
def registrar_usuario():
    data = request.get_json()
    nombre = data.get("nombre")
    email = data.get("email")
    password = data.get("password")  # ¡En producción deberías hashearla!

    cursor.execute(
        "INSERT INTO usuarios (nombre, email, password) VALUES (%s, %s, %s)",
        (nombre, email, password)
    )
    conn.commit()
    return jsonify({"mensaje": "Usuario registrado correctamente"}), 201

@app.route("/login", methods=["POST"])
def check_login():
    data = request.get_json()
    email = data.get("email")
    password = data.get("password")
    cursor.execute(
        "SELECT COUNT(*) FROM usuarios WHERE email = %s AND password = %s",
        (email, password)   
    )
    count = cursor.fetchone()[0]
    if count > 0:
        return jsonify({"mensaje": "Login exitoso"}), 200
    else:
        return jsonify({"mensaje": "Credenciales incorrectas"}), 401

@app.route("/recetas", methods=["POST"])
def save_receta():
    data = request.get_json()
    nombre = data.get("nombre")
    ingredientes = data.get("ingredientes")
    instrucciones = data.get("instrucciones")  # Cambio de "pasos" a "instrucciones" para consistencia
    categoria = data.get("categoria")
    tiempo = data.get("tiempo")
    usuario_email = data.get("usuario_email")  
    
    # Primero obtenemos el ID del usuario a partir de su email
    cursor.execute(
        "SELECT id FROM usuarios WHERE email = %s",
        (usuario_email,)
    )
    
    usuario_result = cursor.fetchone()
    if not usuario_result:
        return jsonify({"mensaje": "Usuario no encontrado"}), 404
    
    usuario_id = usuario_result[0]
    
    # Insertamos la receta con el ID del usuario en lugar del email
    cursor.execute(
        "INSERT INTO recetas (nombre, ingredientes, instrucciones, categoria, tiempo, id) VALUES (%s, %s, %s, %s, %s, %s)",
        (nombre, ingredientes, instrucciones, categoria, tiempo, usuario_id)
    )
    
    conn.commit()
    
    # Obtenemos el ID de la receta recién insertada
    cursor.execute("SELECT lastval()")
    receta_id = cursor.fetchone()[0]
    
    return jsonify({
        "mensaje": "Receta guardada correctamente", 
        "id_receta": receta_id
    }), 201

@app.route("/recetas/buscar", methods=["GET"])
def search_receta():
    nombre = request.args.get("nombre")
    categoria = request.args.get("categoria")
    ingredientes = request.args.get("ingredientes")
    
    # Lista para almacenar los resultados
    recetas = []
    
    # Búsqueda por nombre (búsqueda parcial, no exacta)
    if nombre:
        cursor.execute(
            "SELECT id_receta, nombre, ingredientes, instrucciones, categoria, tiempo FROM recetas WHERE nombre ILIKE %s",
            (f"%{nombre}%",)
        )
        recetas = cursor.fetchall()
    
    # Búsqueda por categoría
    elif categoria:
        cursor.execute(
            "SELECT id_receta, nombre, ingredientes, instrucciones, categoria, tiempo FROM recetas WHERE categoria = %s",
            (categoria,)
        )
        recetas = cursor.fetchall()
    
    # Búsqueda por ingredientes
    elif ingredientes:
        # Dividimos la lista de ingredientes por comas
        ingredientes_lista = ingredientes.split(',')
        
        # Construimos una condición OR para cada ingrediente
        placeholders = []
        params = []
        
        for ingrediente in ingredientes_lista:
            placeholders.append("ingredientes ILIKE %s")
            params.append(f"%{ingrediente.strip()}%")
        
        # Unimos las condiciones con OR
        condicion_sql = " AND ".join(placeholders)
        
        # Ejecutamos la consulta
        sql = f"SELECT id_receta, nombre, ingredientes, instrucciones, categoria, tiempo FROM recetas WHERE {condicion_sql}"
        cursor.execute(sql, params)
        recetas = cursor.fetchall()
    
    # Transformamos los resultados a formato JSON
    resultado = []
    for receta in recetas:
        resultado.append({
            "id_receta": receta[0],
            "nombre": receta[1],
            "ingredientes": receta[2],
            "instrucciones": receta[3],
            "categoria": receta[4],
            "tiempo": receta[5]
        })
    
    return jsonify(resultado), 200

@app.route("/recetas/<int:id>", methods=["GET"])
def get_receta(id):
    cursor.execute(
        """SELECT r.id_receta, r.nombre, r.ingredientes, r.instrucciones, r.categoria, r.tiempo,
                 u.email as usuario_email, u.nombre as usuario_nombre 
          FROM recetas r 
          LEFT JOIN usuarios u ON u.id = r.id 
          WHERE r.id_receta = %s""",
        (id,)
    )
    
    receta = cursor.fetchone()
    
    if not receta:
        return jsonify({"mensaje": "Receta no encontrada"}), 404
    
    # Comprueba si algún valor es None para evitar errores
    valores = []
    for i in range(8):
        valores.append(receta[i] if i < len(receta) and receta[i] is not None else "")
    
    return jsonify({
        "id_receta": valores[0],  # Importante: cambia a "id" para que el frontend lo reconozca
        "nombre": valores[1],
        "ingredientes": valores[2],
        "instrucciones": valores[3],
        "categoria": valores[4],
        "tiempo": valores[5],
        "usuario_email": valores[6],
        "usuario_nombre": valores[7]
    }), 200
    
if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000)
