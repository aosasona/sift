package core_test

import (
	core "sift"
	"testing"
)

func TestExtractURLContent(t *testing.T) {
	url := "https://example.com"

	expectedExcerpt := "This domain is for use in illustrative examples in documents. You may use this domain in literature without prior coordination or asking for permission."
	expectedMarkdown := `This domain is for use in illustrative examples in documents. You may use this domain in literature without prior coordination or asking for permission.

[More information...](https://www.iana.org/domains/example)`

	article, err := core.ExtractURLContent(url)
	if err != nil {
		t.Fatalf("Failed to extract content from URL: %v", err)
	}

	if article.Title != "Example Domain" {
		t.Errorf("Expected title 'Example Domain', got '%s'", article.Title)
	}

	if article.Author != "" {
		t.Errorf("Expected author to be empty, got '%s'", article.Author)
	}

	if article.Excerpt != expectedExcerpt {
		t.Errorf(
			"Expected excerpt to be '%s', got '%s'",
			expectedExcerpt,
			article.Excerpt,
		)
	}

	if article.MarkdownContent != expectedMarkdown {
		t.Errorf(
			"Expected markdown content to be '%s', got '%s'",
			expectedMarkdown,
			article.MarkdownContent,
		)
	}

	if article.PublishedAt != 0 {
		t.Errorf("Expected published time to be empty, got '%v'", article.PublishedAt)
	}
}
