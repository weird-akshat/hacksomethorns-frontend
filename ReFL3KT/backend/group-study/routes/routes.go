package routes

import (
	"gs-api/controllers"
	"log"

	"github.com/gin-gonic/gin"
)

func SetupRoutes() *gin.Engine {
	router := gin.Default()

	// Add root handler for testing connectivity
	router.GET("/", func(c *gin.Context) {
		c.JSON(200, gin.H{"status": "Server is running", "message": "Group Study API"})
	})

	// Add health check
	router.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{"status": "healthy"})
	})

	api := router.Group("/api/v1")
	{
		api.POST("/groups", controllers.CreateGroup)
		api.POST("/groups/join", controllers.JoinGroup)
		api.DELETE("/groups/:groupCode/users/:userID", controllers.LeaveGroup)
		api.GET("/groups/:groupCode/users/:userID/progress", controllers.GetUserProgress)
		api.PUT("/groups/:groupCode/users/:userID/progress", controllers.UpdateProgress)
		api.GET("/groups/:groupCode/progress", controllers.GetGroupProgress)
		api.POST("/groups/:groupCode/tasks", controllers.AddTaskToGroup)
	}

	// Log registered routes
	log.Println("Registered routes:")
	for _, route := range router.Routes() {
		log.Printf("%s %s", route.Method, route.Path)
	}

	return router
}
