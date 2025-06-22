package models

type Goal struct {
	ID   int    `json:"id" gorm:"primaryKey"`
	Name string `json:"name"`
}
