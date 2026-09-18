# Progress v3

Versión preparada para funcionar con Supabase: cuentas separadas, aprobación de usuarios, objetivos e historial protegidos por Row Level Security y panel de administración.

## 1. Crear el proyecto
1. Entra en Supabase y crea un proyecto nuevo.
2. En el proyecto, abre **SQL Editor**.
3. Copia todo el contenido de `schema.sql` y ejecútalo.
4. En **Authentication > Providers**, deja activo Email/Password.
5. Si quieres que los usuarios tengan que confirmar su correo, deja activada la confirmación de email. Si prefieres probarlo más rápido, puedes desactivarla temporalmente.

## 2. Crear la cuenta administradora
En Progress pulsa **Crear cuenta** y utiliza:
- Usuario: `admin`
- Correo: `raul.sanchezbenavente.tseas@gmail.com`
- Contraseña: introdúcela tú mismo en el formulario. No está escrita en ningún archivo del proyecto.

El trigger de `schema.sql` reconoce ese correo y crea el perfil como administrador y aprobado.

## 3. Configurar Progress
Abre `config.js` y rellena:
- `supabaseUrl`: URL de tu proyecto.
- `supabasePublishableKey`: publishable key del proyecto.

Usa únicamente la **publishable key** en el navegador. Nunca pongas una secret/service_role key en `config.js`.

## 4. Usuarios normales
Los usuarios se registran con usuario, correo y contraseña. Su cuenta queda `approved=false` y no pueden entrar hasta que el administrador la apruebe.

## 5. Qué incluye v3
- Login y registro con Supabase Auth.
- Administrador separado del perfil personal.
- Aprobación/revocación de usuarios.
- Inicio diario con objetivos horizontales.
- Checkbox a la izquierda.
- Objetivos booleanos, de tiempo y de cantidad.
- Porcentaje objetivo/real y posibilidad de superar 100%.
- Historial por días y calendario mensual.
- Estadísticas básicas por objetivo.
- Perfil independiente por usuario.
- Protección de datos con RLS.
- Diseño responsive, naranja suave y barra lateral derecha.

## Importante
La contraseña del administrador NO se guarda en este proyecto. La contraseña se gestiona por Supabase Auth. Si alguna contraseña real se ha compartido en un chat o documento, es recomendable sustituirla por una nueva antes de publicar la aplicación.
