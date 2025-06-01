package core

import (
	"context"
	"time"

	htmltomarkdown "github.com/JohannesKaufmann/html-to-markdown/v2"
	"github.com/JohannesKaufmann/html-to-markdown/v2/converter"
	readability "github.com/go-shiori/go-readability"
)

type Article struct {
	Title           string
	Author          string
	HTMLContent     string
	TextContent     string
	MarkdownContent string
	Length          int
	Excerpt         string
	SiteName        string
	Image           string
	Favicon         string
	Language        string
	PublishedAt     int64 // Unix timestamp
	ModifiedAt      int64 // Unix timestamp
}

func ExtractURLContent(url string) (*Article, error) {
	ctx := context.Background()

	article, err := readability.FromURL(url, 30*time.Second)
	if err != nil {
		return &Article{}, err
	}

	markdown, err := htmltomarkdown.ConvertString(
		article.Content,
		converter.WithContext(ctx),
	)
	if err != nil {
		return &Article{}, err
	}

	var publishedAt, modifiedAt int64

	if article.PublishedTime != nil {
		publishedAt = article.PublishedTime.Unix()
	}

	if article.ModifiedTime != nil {
		modifiedAt = article.ModifiedTime.Unix()
	}

	return &Article{
		Title:           article.Title,
		Author:          article.Byline,
		HTMLContent:     article.Content,
		TextContent:     article.TextContent,
		MarkdownContent: markdown,
		Length:          article.Length,
		Excerpt:         article.Excerpt,
		SiteName:        article.SiteName,
		Image:           article.Image,
		Favicon:         article.Favicon,
		Language:        article.Language,
		PublishedAt:     publishedAt,
		ModifiedAt:      modifiedAt,
	}, nil
}
