package eu.meiyu.training.feature.card.entity;

import java.util.List;

public record CardInfoTable (String caption, List<String> headers, List<List<String>> rows) {
}
