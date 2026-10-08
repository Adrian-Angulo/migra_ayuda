# Ejemplo: Flujo de Procesamiento de Órdenes (Microservicios)

Este ejemplo muestra la interacción entre servicios desacoplados utilizando llamadas síncronas (REST/gRPC), eventos asíncronos (Event Bus / Kafka) y fragmentos combinados (`alt`, `opt`).

```mermaid
sequenceDiagram
    autonumber
    actor Cliente
    participant Gateway as API Gateway
    participant OrderSvc as Order Service
    participant PaySvc as Payment Service
    participant EventBus as Message Broker
    participant InventorySvc as Inventory Service

    Cliente->>Gateway: POST /orders (items, pago)
    activate Gateway

    Gateway->>OrderSvc: createOrder()
    activate OrderSvc

    OrderSvc->>PaySvc: processPayment(monto, tarjeta)
    activate PaySvc

    alt Pago Aprobado
        PaySvc-->>OrderSvc: 200 OK (transactionId)
        OrderSvc-)EventBus: OrderCreatedEvent (Async)
        activate EventBus
        EventBus-)InventorySvc: Reservar Stock
        deactivate EventBus

        OrderSvc-->>Gateway: 201 Created (orderId)
        Gateway-->>Cliente: Orden Confirmada
    else Pago Rechazado
        PaySvc-->>OrderSvc: 402 Payment Required
        OrderSvc-->>Gateway: 400 Bad Request (Error de pago)
        Gateway-->>Cliente: Notificar error de fondos/tarjeta
    end

    deactivate PaySvc
    deactivate OrderSvc
    deactivate Gateway
```
