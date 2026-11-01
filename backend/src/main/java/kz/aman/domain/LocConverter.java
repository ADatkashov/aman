package kz.aman.domain;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.persistence.AttributeConverter;
import jakarta.persistence.Converter;

/** Stores {@link Loc} as a small JSON document in a text column. */
@Converter
public class LocConverter implements AttributeConverter<Loc, String> {

    private static final ObjectMapper MAPPER = new ObjectMapper();

    @Override
    public String convertToDatabaseColumn(Loc attribute) {
        if (attribute == null) {
            return null;
        }
        try {
            return MAPPER.writeValueAsString(attribute);
        } catch (JsonProcessingException e) {
            throw new IllegalStateException("Cannot serialize localized text", e);
        }
    }

    @Override
    public Loc convertToEntityAttribute(String dbData) {
        if (dbData == null) {
            return null;
        }
        try {
            return MAPPER.readValue(dbData, Loc.class);
        } catch (JsonProcessingException e) {
            throw new IllegalStateException("Cannot read localized text", e);
        }
    }
}
