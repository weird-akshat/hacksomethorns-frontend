package models

import (
	"crypto/rand"
	"math/big"
)

type GroupStudy struct {
	GroupCode      int64   `json:"group_code" gorm:"primaryKey"`
	GoalID         int     `json:"goal_id"`
	TaskID         int     `json:"task_id"`
	UserID         int     `json:"user_id"`
	GoalName       string  `json:"goal_name"`
	TaskName       string  `json:"task_name"`
	UserName       string  `json:"user_name"`
	GoalCompletion float64 `json:"goal_completion" gorm:"type:decimal(5,2)"`
}

func GenerateGroupCode() (int64, error) {
	// Generate cryptographically secure random number
	max := big.NewInt(999999999)
	n, err := rand.Int(rand.Reader, max)
	if err != nil {
		return 0, err
	}
	return n.Int64() + 100000000, nil // Ensure 9-digit number
}
