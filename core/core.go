package core

import (
	"fmt"
	"net/http"
	"net/url"
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

func ExtractURLContent(link string) (*Article, error) {
	article, err := readability.FromURL(link, 30*time.Second, func(req *http.Request) {
		req.Header.Set(
			"User-Agent",
			"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.1 Safari/605.1.15",
		)
	})
	if err != nil {
		return &Article{}, err
	}

	parsedUrl, _ := url.Parse(link)
	baseUrl := fmt.Sprintf("%s://%s", parsedUrl.Scheme, parsedUrl.Host)

	markdown, err := htmltomarkdown.ConvertString(
		article.Content,
		converter.WithDomain(baseUrl),
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
