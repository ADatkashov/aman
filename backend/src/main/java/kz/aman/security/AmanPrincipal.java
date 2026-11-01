package kz.aman.security;

import kz.aman.domain.Role;

/** Authenticated caller extracted from a verified access token. */
public record AmanPrincipal(long userId, Role role) {}
