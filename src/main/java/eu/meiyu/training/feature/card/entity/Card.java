package eu.meiyu.training.feature.card.entity;

import jakarta.persistence.*;
import org.hibernate.annotations.BatchSize;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "card")
public class Card {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true, length = 200)
    private String name;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "kind_id", nullable = false)
    private Kind kind;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "category_id", nullable = false)
    private Category category;

    @Column(nullable = false, columnDefinition = "text")
    private String description;

    @BatchSize(size = 50)
    @ElementCollection
    @CollectionTable(name = "card_fact", joinColumns = @JoinColumn(name = "card_id"))
    @OrderColumn(name = "position")
    private List<CardFact> facts = new ArrayList<>();

    @Column(name = "example_code", columnDefinition = "text")
    private String exampleCode;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "info_tables", columnDefinition = "jsonb")
    private List<CardInfoTable> infoTables = new ArrayList<>();

    @BatchSize(size = 50)
    @ManyToMany
    @JoinTable(name = "card_related",
        joinColumns = @JoinColumn(name = "card_id"),
        inverseJoinColumns = @JoinColumn(name = "related_card_id"))
    @OrderColumn(name = "position")
    private List<Card> relatedCards = new ArrayList<>();

    @Column(name = "source_url", length = 500)
    private String sourceUrl;

    protected Card() {
    }

    public Card(String name, Kind kind, Category category, String description) {
        this.name = name;
        this.kind = kind;
        this.category = category;
        this.description = description;
    }

    public Long getId() { return id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public Kind getKind() { return kind; }
    public void setKind(Kind kind) { this.kind = kind; }

    public Category getCategory() { return category; }
    public void setCategory(Category category) { this.category = category; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public List<CardFact> getFacts() { return facts; }
    public void setFacts(List<CardFact> facts) { this.facts = facts; }

    public String getExampleCode() { return exampleCode; }
    public void setExampleCode(String exampleCode) { this.exampleCode = exampleCode; }

    public List<CardInfoTable> getInfoTables() { return infoTables; }
    public void setInfoTables(List<CardInfoTable> infoTables) { this.infoTables = infoTables; }

    public List<Card> getRelatedCards() { return relatedCards; }
    public void setRelatedCards(List<Card> relatedCards) { this.relatedCards = relatedCards; }

    public String getSourceUrl() { return sourceUrl; }
    public void setSourceUrl(String sourceUrl) { this.sourceUrl = sourceUrl; }
}