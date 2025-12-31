// ABOUTME: HTTP handlers for the example API
// ABOUTME: Provides health check and user listing endpoints

package handlers

import (
	"encoding/json"
	"net/http"
)

// HealthCheck returns server status
func HealthCheck(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{"status": "ok"})
}

// ListUsers returns a list of example users
func ListUsers(w http.ResponseWriter, r *http.Request) {
	users := []map[string]string{
		{"id": "1", "name": "Alice"},
		{"id": "2", "name": "Bob"},
	}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(users)
}
