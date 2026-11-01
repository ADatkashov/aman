package kz.aman.domain;

/** Text in the three supported languages (ru, en, kk). */
public record Loc(String ru, String en, String kk) {

    public static Loc of(String ru, String en, String kk) {
        return new Loc(ru, en, kk);
    }

    public static Loc plain(String value) {
        return new Loc(value, value, value);
    }
}
