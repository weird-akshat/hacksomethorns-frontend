package config

import (
	"gs-api/models"
	"log"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

var DB *gorm.DB

func ConnectDatabase() {
	dsn := "host=localhost user=journal_user password=pass123 dbname=journal_db port=5432 sslmode=disable"

	database, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		log.Fatal("Failed to connect to database:", err)
	}

	// Auto-migrate the new group study table
	err = database.AutoMigrate(&models.GroupStudy{})
	if err != nil {
		log.Fatal("Failed to migrate database:", err)
	}

	DB = database
}
