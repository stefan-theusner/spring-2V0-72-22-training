package eu.meiyu.training.feature.card.entity;

import jakarta.persistence.*;

@Entity
@Table(name="card_category")
public class Category {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true, length = 20)
    private String code;

    @Column(nullable = false, unique = true, length = 100)
    private String name;

    protected Category() {
    }

    public Long getId() { return id; }
    public String getCode() { return code; }
    public String getName() { return name; }

}
