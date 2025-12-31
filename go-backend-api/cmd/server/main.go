// ABOUTME: Entry point for the example Go API server
// ABOUTME: Demonstrates a minimal HTTP server for team workflow testing

package main

import (
	"log"
	"net/http"

	"github.com/claudeup/claudeup-test-repos/go-backend-api/internal/handlers"
)

func main() {
	mux := http.NewServeMux()
	mux.HandleFunc("/health", handlers.HealthCheck)
	mux.HandleFunc("/api/users", handlers.ListUsers)

	log.Println("Starting server on :8080")
	if err := http.ListenAndServe(":8080", mux); err != nil {
		log.Fatal(err)
	}
}
