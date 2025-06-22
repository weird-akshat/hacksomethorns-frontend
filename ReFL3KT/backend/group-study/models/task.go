package models

type Task struct {
	ID     int    `json:"id" gorm:"primaryKey"`
	Name   string `json:"name"`
	GoalID int    `json:"goal_id"`
}
