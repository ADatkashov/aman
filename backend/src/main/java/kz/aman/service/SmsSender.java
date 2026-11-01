package kz.aman.service;

/** Delivery channel for one-time codes. Production wires an SMS gateway here. */
public interface SmsSender {
    void send(String phone, String message);
}
