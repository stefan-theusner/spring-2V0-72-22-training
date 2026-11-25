package eu.meiyu.training.feature.card.entity;

import jakarta.persistence.*;

@Entity
@Table(name="card_kind")
public class Kind {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true, length = 100)
    private String name;

    @Column(nullable = false, unique = true)
    private String hint;

    protected Kind() {
    }

    public Long getId() { return id; }
    public String getHint() { return hint; }
    public String getName() { return name; }

}
