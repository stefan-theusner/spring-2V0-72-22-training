package eu.meiyu.training.feature.card.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;

@Embeddable
public class CardFact {

    @Column(nullable = false, columnDefinition = "text")
    private String text;

    @Column(nullable = false)
    private boolean important;

    protected CardFact() {
    }

    public CardFact(String text, boolean important) {
        this.text = text;
        this.important = important;
    }

    public String getText() { return text; }
    public boolean isImportant() { return important; }
}