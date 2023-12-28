package main

import (
	"bytes"
	"flag"
	"fmt"
	"io"
	"io/ioutil"
	"mime/multipart"
	"net/http"
	"os"
	"path/filepath"
)

func main() {
	uploadCmd := flag.NewFlagSet("upload", flag.ExitOnError)
	downloadCmd := flag.NewFlagSet("download", flag.ExitOnError)
	deleteCmd := flag.NewFlagSet("delete", flag.ExitOnError)

	uploadFilename := uploadCmd.String("file", "", "File path to upload")
	downloadURL := downloadCmd.String("url", "", "URL to download the file from")
	deleteURL := deleteCmd.String("url", "", "URL to delete the file")

	if len(os.Args) < 2 {
		printUsage()
		os.Exit(1)
	}

	switch os.Args[1] {
	case "upload":
		uploadCmd.Parse(os.Args[2:])
		if *uploadFilename != "" {
			err := uploadFile(*uploadFilename)
			if err != nil {
				fmt.Println("Error uploading file:", err)
				os.Exit(1)
			}
			fmt.Println("File uploaded successfully")
		} else {
			printUsage()
		}
	case "download":
		downloadCmd.Parse(os.Args[2:])
		if *downloadURL != "" {
			err := downloadFile(*downloadURL)
			if err != nil {
				fmt.Println("Error downloading file:", err)
				os.Exit(1)
			}
			fmt.Println("File downloaded successfully")
		} else {
			printUsage()
		}
	case "delete":
		deleteCmd.Parse(os.Args[2:])
		if *deleteURL != "" {
			err := deleteFile(*deleteURL)
			if err != nil {
				fmt.Println("Error deleting file:", err)
				os.Exit(1)
			}
			fmt.Println("File deleted successfully")
		} else {
			printUsage()
		}
	default:
		fmt.Println("Invalid command")
		printUsage()
		os.Exit(1)
	}
}

func uploadFile(filename string) error {
	file, err := os.Open(filename)
	if err != nil {
		return err
	}
	defer file.Close()

	body := &bytes.Buffer{}
	writer := multipart.NewWriter(body)
	part, err := writer.CreateFormFile("file", filepath.Base(file.Name()))
	if err != nil {
		return err
	}
	_, err = io.Copy(part, file)
	if err != nil {
		return err
	}
	writer.Close()

	req, err := http.NewRequest("POST", "http://127.0.0.1:5000/files/", body)
	if err != nil {
		return err
	}
	req.Header.Set("Content-Type", writer.FormDataContentType())

	printHTTPRequest(req)

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	printHTTPResponse(resp)

	return nil
}

func downloadFile(url string) error {
	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		return err
	}

	printHTTPRequest(req)

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	printHTTPResponse(resp)

	out, err := os.Create(filepath.Base(url))
	if err != nil {
		return err
	}
	defer out.Close()

	_, err = io.Copy(out, resp.Body)
	return err
}

func deleteFile(url string) error {
	req, err := http.NewRequest("DELETE", url, nil)
	if err != nil {
		return err
	}

	printHTTPRequest(req)

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	printHTTPResponse(resp)

	return nil
}

func printHTTPRequest(req *http.Request) {
	fmt.Println("Request:")
	fmt.Printf("Method: %s\nURL: %s\nHeaders: %v\n", req.Method, req.URL, req.Header)
	// Note: Printing the body of a request here is non-trivial as it can be a binary stream
}

func printHTTPResponse(resp *http.Response) {
	fmt.Println("Response:")
	fmt.Printf("Status: %s\nHeaders: %v\n", resp.Status, resp.Header)
	bodyBytes, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		fmt.Println("Error reading response body:", err)
		return
	}
	// Reset the response body to the original state
	resp.Body = ioutil.NopCloser(bytes.NewBuffer(bodyBytes))
	fmt.Println("Body:", string(bodyBytes))
}

func printUsage() {
	fmt.Println("Usage:")
	fmt.Println("  upload --file <file_path>    Upload a file.")
	fmt.Println("  download --url <file_url>    Download a file.")
	fmt.Println("  delete --url <file_url>      Delete a file.")
}
