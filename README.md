# Havenly

Plataforma de reservas construida con **Ruby on Rails 8.1.3.1** y **Ruby 4.0**. El objetivo no es solo tener un CRUD funcional, sino demostrar decisiones de arquitectura reales: integridad de datos bajo concurrencia, protección contra accesos no autorizados, y una suite de tests que documenta el comportamiento esperado del sistema.

## Stack

- **Ruby** 4.0
- **Rails** 8.1.3.1
- **Base de datos**: SQLite (desarrollo/test) — pensado para migrar a PostgreSQL antes de producción
- **Autenticación**: Devise
- **Archivos**: Active Storage (fotos de listings)
- **Testing**: RSpec + FactoryBot
- **Frontend**: ERB + Turbo (Hotwire)

## Modelo de dominio

```
User (Devise)
  role: enum { guest, host }  — un usuario puede publicar y reservar
  has_many :listings, foreign_key: :host_id
  has_many :bookings, foreign_key: :guest_id

Listing
  belongs_to :host, class_name: "User"
  has_many :bookings, dependent: :destroy
  has_many_attached :photos

Booking
  belongs_to :listing
  belongs_to :guest, class_name: "User"
  enum status: { pending, confirmed, cancelled }
```

## Features implementadas

- Autenticación con Devise, roles `guest`/`host` sobre un mismo modelo `User`
- CRUD de listings, con vista pública (solo lectura) y vista de gestión para el host (`/host/listings`)
- Fotos de listings con Active Storage y variantes redimensionadas
- Sistema de reservas con validación de no-solapamiento de fechas
- Protección anti-IDOR: un usuario nunca puede ver, editar o cancelar recursos de otro cambiando el `id` en la URL
- Cálculo de precio total en el servidor (nunca se confía en datos del formulario)
-  Pagos con Stripe Checkout: la reserva nace en `pending` y solo pasa a `confirmed` cuando Stripe confirma el pago vía webhook, nunca desde el navegador
- Tests de modelo y de request específs (RSpec + FactoryBot) cubriendo reglas de negocio y casos de seguridad

### Validación de no-solapamiento de reservas

Dos rangos de fechas `[a, b)` y `[c, d)` se solapan si `a < d AND c < b`. Esta lógica vive en un scope de `Booking`:

```ruby
scope :overlapping, ->(listing_id, check_in, check_out) {
  where(listing_id: listing_id)
    .where.not(status: :cancelled)
    .where("check_in < ? AND check_out > ?", check_out, check_in)
}
```

Los tests cubren explícitamente los casos límite (una reserva que termina el mismo día que otra empieza **no** se considera solapamiento), que son los que suelen esconder bugs sutiles en este tipo de lógica.

### Protección contra IDOR (Insecure Direct Object Reference)

Todos los controllers que gestionan recursos privados (`Host::ListingsController`, `BookingsController`) resuelven el registro **siempre** a través de la asociación del usuario actual:

```ruby
@listing = current_user.listings.find(params[:id])
@booking = current_user.bookings.find(params[:id])
```

en vez de `Listing.find(params[:id])`. Esto hace que intentar acceder al recurso de otro usuario devuelva `404` en lugar de exponer o modificar datos ajenos. Cubierto explícitamente en los request specs.

### Precio calculado en el servidor

El formulario de reserva solo envía `check_in`/`check_out`; el `total_price` se calcula en el controller a partir del `price_per_night` del listing, evitando que un cliente manipule el precio final desde el HTML.

### Confirmación de pago solo vía webhook
 
El `success_url` al que Stripe redirige tras el pago **nunca** confirma la reserva — el usuario podría cerrar la pestaña antes de llegar, o manipular la URL manualmente. La única fuente de verdad es `StripeWebhooksController`, que verifica la firma criptográfica del evento (`Stripe::Webhook.construct_event`) y solo entonces marca el `Booking` como `confirmed`. En los tests, esta verificación se stubea para probar la lógica propia sin depender de generar firmas HMAC reales.
 
Un detalle de integración que vale la pena documentar: Turbo (Hotwire) intercepta los submits de formulario por `fetch()`, lo cual rompe el redirect cross-origin hacia `checkout.stripe.com` por restricciones de CORS del navegador. Solución: `data: { turbo: false }` en el formulario de creación de booking, forzando una navegación de página completa para esa acción específica.

## Configuración del entorno de desarrollo

```bash
git clone <repo>
cd havenly
bundle install
rails db:create db:migrate
rails active_storage:install
rails db:migrate
rails server
```

### Nota sobre Windows + Ruby 4.0

Este proyecto se desarrolló en Windows con Ruby 4.0, una combinación muy reciente que expuso un par de incompatibilidades conocidas al momento de escribir esto:

- **`reline`/`fiddle`**: la consola interactiva (`rails console`) requiere agregar `gem "fiddle"` explícitamente al `Gemfile`, ya que dejó de venir incluida por defecto en Ruby 4.0.
- **Gema `json` 3.0.0**: causaba un `ArgumentError` intermitente ("wrong number of arguments") al acceder a la sesión (afectaba `csrf_meta_tags`, `link_to`, y helpers de Devise). Solución: fijar `gem "json", "< 3.0"` en el `Gemfile`. Reportado en [rails/rails#58685](https://github.com/rails/rails/issues/58685).

## Testing
 
```bash
bundle exec rspec
```
 
Cobertura actual:
- Specs de modelo para `User`, `Listing` y `Booking` (validaciones, asociaciones, lógica de solapamiento)
- Request specs para `Host::ListingsController`, `BookingsController` y `StripeWebhooksController` (autorización, casos felices, casos de seguridad, confirmación de pago)

### Probar pagos en local
 
```bash
stripe listen --forward-to localhost:3000/webhooks/stripe --events checkout.session.completed
```
 
Copia el `whsec_...` que imprime a `stripe.webhook_secret` en `rails credentials:edit`. Tarjeta de prueba: `4242 4242 4242 4242`, cualquier fecha futura, cualquier CVC.
